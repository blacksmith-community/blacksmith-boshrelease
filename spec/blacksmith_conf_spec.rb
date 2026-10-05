require 'rspec'
require 'json'
require 'yaml'
require 'bosh/template/test'

RELEASE_ROOT = File.expand_path('..', __dir__)

# Properties that have no default in the job spec but that the template reads.
BASE_PROPERTIES = {
  'env' => 'test',
  'shareable' => false,
  'broker' => {
    'username' => 'blacksmith',
    'password' => 'broker-secret',
  },
}.freeze

# Spec helpers. Overrides passed to render_conf must use string keys, and
# arrays in overrides replace the base value rather than merging with it.
module BlacksmithConfSpecHelpers
  def deep_merge(base, overrides)
    base.merge(overrides) do |_key, old, new|
      old.is_a?(Hash) && new.is_a?(Hash) ? deep_merge(old, new) : new
    end
  end

  # Renders blacksmith.conf with BASE_PROPERTIES plus the given overrides, and
  # returns the rendered text. The job spec defaults still apply underneath.
  def render_conf(overrides = {})
    release = Bosh::Template::Test::ReleaseDir.new(RELEASE_ROOT)
    job = release.job('blacksmith')
    template = job.template('config/blacksmith.conf')
    template.render(deep_merge(BASE_PROPERTIES, overrides))
  end

  # Renders and parses the result as YAML.
  def render_conf_yaml(overrides = {})
    YAML.safe_load(render_conf(overrides))
  end
end

RSpec.configure { |c| c.include BlacksmithConfSpecHelpers }

RSpec.describe 'blacksmith.conf' do
  describe 'bosh.request_timeout' do
    it 'defaults to 60 seconds' do
      expect(render_conf_yaml['bosh']['request_timeout']).to eq(60)
    end

    it 'renders an override' do
      conf = render_conf_yaml('bosh' => { 'request_timeout' => 15 })
      expect(conf['bosh']['request_timeout']).to eq(15)
    end

    ['60s', 0, -5, 1.5].each do |bad|
      it "rejects #{bad.inspect} and says what to set instead" do
        expect { render_conf('bosh' => { 'request_timeout' => bad }) }
          .to raise_error(RuntimeError, /bosh\.request_timeout.*#{Regexp.escape(bad.to_s)}.*positive whole number of seconds/m)
      end
    end
  end

  describe 'bosh credentials' do
    it 'keeps a password with a colon and a hash as one string' do
      conf = render_conf_yaml('bosh' => { 'password' => 'a:b#c' })
      expect(conf['bosh']['password']).to eq('a:b#c')
    end

    it 'keeps a numeric password a string' do
      conf = render_conf_yaml('bosh' => { 'password' => 12345 })
      expect(conf['bosh']['password']).to eq('12345')
    end

    it 'keeps a username and an address as strings' do
      conf = render_conf_yaml('bosh' => { 'username' => 'ops: admin', 'address' => 'https://10.0.0.6:25555' })
      expect(conf['bosh']).to include('username' => 'ops: admin', 'address' => 'https://10.0.0.6:25555')
    end

    {
      'a colon-space followed by space-hash' => 'a: b #c',
      'a double quote and a backslash' => '"pa\\ss" word',
      'non-ASCII characters' => 'pässwörd',
      'an empty string' => '',
    }.each do |label, password|
      it "round-trips a password with #{label} exactly" do
        conf = YAML.safe_load(render_conf('bosh' => { 'password' => password }))
        expect(conf['bosh']['password']).to eq(password)
      end
    end
  end

  describe 'quoting of the remaining credentials' do
    awkward = {
      'a colon-space followed by space-hash' => 'a: b #c',
      'a double quote and a backslash' => '"pa\\ss" word',
      'an empty string' => '',
    }

    shield = {
      'enabled' => true,
      'address' => 'https://shield.example.com',
      'agent' => '10.0.0.9:5444',
      'tenant' => 'default',
      'store' => 'local',
    }

    awkward.each do |label, value|
      it "round-trips a shield password with #{label}" do
        conf = render_conf_yaml('shield' => shield.merge('auth_method' => 'local', 'username' => 'ops', 'password' => value))
        expect(conf['shield']['password']).to eq(value)
      end

      it "round-trips a shield token with #{label}" do
        conf = render_conf_yaml('shield' => shield.merge('auth_method' => 'token', 'token' => value))
        expect(conf['shield']['token']).to eq(value)
      end

      it "round-trips a broker password with #{label}" do
        conf = render_conf_yaml('broker' => { 'password' => value })
        expect(conf['broker']['password']).to eq(value)
      end

      it "round-trips a bosh network name with #{label}" do
        conf = render_conf_yaml('bosh' => { 'cloud-config' => 'networks: []', 'network' => value })
        expect(conf['bosh']['network']).to eq(value)
      end
    end

    it 'round-trips a cf name, username, and password with a double quote and a backslash' do
      value = awkward['a double quote and a backslash']
      apis = { 'one' => { 'name' => value, 'endpoint' => 'https://api.example.com', 'username' => value, 'password' => value } }
      conf = render_conf_yaml('broker' => { 'cf' => { 'apis' => apis } })
      expect(conf['broker']['cf']['apis']['one']).to include('name' => value, 'username' => value, 'password' => value)
    end

    it 'keeps a numeric shield token and a numeric broker password strings' do
      conf = render_conf_yaml('broker' => { 'password' => 12345 },
                              'shield' => shield.merge('auth_method' => 'token', 'token' => 98765))
      expect(conf['broker']['password']).to eq('12345')
      expect(conf['shield']['token']).to eq('98765')
    end

    it 'renders every cf api in a map with its own awkward credentials' do
      apis = {
        'a: b' => { 'name' => 'x"y', 'endpoint' => 'https://a.example.com', 'username' => 'u #1', 'password' => 'p\\q' },
        'two' => { 'name' => 'two', 'endpoint' => 'https://b.example.com', 'username' => 'u2', 'password' => '"' },
      }
      conf = render_conf_yaml('broker' => { 'cf' => { 'apis' => apis } })
      expect(conf['broker']['cf']['apis'].keys).to eq(['a: b', 'two'])
      expect(conf['broker']['cf']['apis']['a: b']).to include('name' => 'x"y', 'username' => 'u #1', 'password' => 'p\\q')
      expect(conf['broker']['cf']['apis']['two']['password']).to eq('"')
    end

    it 'keeps numbers and booleans as their own YAML types' do
      conf = render_conf_yaml('broker' => { 'port' => 3100, 'tls' => { 'enabled' => true, 'port' => 8443, 'reuse-after' => 3 } },
                              'shield' => shield.merge('auth_method' => 'token', 'token' => 't', 'skip_ssl_validation' => false))
      expect(conf['broker']['port']).to eq(3100)
      expect(conf['broker']['tls']).to include('enabled' => true, 'port' => 8443, 'reuse_after' => 3)
      expect(conf['shield']['enabled']).to eq(true)
      expect(conf['shield']['skip_ssl_validation']).to eq(false)
    end
  end

  describe 'credhub cleanup' do
    let(:connection) do
      {
        'url' => 'https://10.0.0.6:8844',
        'ca_cert' => '-----BEGIN CERTIFICATE-----\nabc\n-----END CERTIFICATE-----',
        'client_secret' => 's3cret',
        'director_name' => 'my-director',
      }
    end

    it 'renders cleanup on with a dry-run sweep and an empty connection when no credhub property is set' do
      credhub = render_conf_yaml['credhub']
      expect(credhub['cleanup']['enabled']).to eq(true)
      expect(credhub['cleanup']['sweep']).to eq('dry-run')
      expect(credhub).to include('url' => '', 'ca_cert' => '', 'client_secret' => '', 'director_name' => '')
    end

    it 'renders all four connection values when all four are set' do
      credhub = render_conf_yaml('credhub' => connection)['credhub']
      expect(credhub).to include(connection)
      expect(credhub['cleanup']['enabled']).to eq(true)
    end

    it 'fails with two of the four set and names the other two' do
      partial = connection.slice('url', 'ca_cert')
      expect { render_conf('credhub' => partial) }
        .to raise_error(RuntimeError, /credhub\.client_secret, credhub\.director_name/)
    end

    it 'does not name a property that is set when it fails' do
      partial = connection.slice('url', 'ca_cert')
      expect { render_conf('credhub' => partial) }
        .to raise_error(RuntimeError) { |e| expect(e.message).not_to match(/credhub\.url|credhub\.ca_cert/) }
    end

    it 'renders a sweep of false as off' do
      credhub = render_conf_yaml('credhub' => { 'cleanup' => { 'sweep' => false } })['credhub']
      expect(credhub['cleanup']['sweep']).to eq('off')
    end

    it 'keeps the broker deployment first in the protected list' do
      credhub = render_conf_yaml('credhub' => { 'cleanup' => { 'protected_deployments' => ['other-one'] } })['credhub']
      expect(credhub['cleanup']['protected_deployments']).to eq(['my-deployment', 'other-one'])
    end

    it 'puts the job deployment name first in the protected list by default' do
      expect(render_conf_yaml['credhub']['cleanup']['protected_deployments'].first).to eq('my-deployment')
    end

    it 'renders no credhub block when cleanup is disabled' do
      expect(render_conf_yaml('credhub' => { 'cleanup' => { 'enabled' => false } })).not_to have_key('credhub')
    end
  end
end
