require 'rspec'
require 'json'
require 'yaml'
require 'bosh/template/test'

RELEASE_ROOT = File.expand_path('..', __dir__)

# Properties that have no default in the job spec but that the template reads.
TEST_CA_PEM = "-----BEGIN CERTIFICATE-----\nMIIBtestca\n-----END CERTIFICATE-----\n".freeze

BASE_PROPERTIES = {
  'env' => 'test',
  'shareable' => false,
  'bosh' => {
    'ca_cert' => TEST_CA_PEM,
  },
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
  def render_conf(overrides = {}, base = BASE_PROPERTIES)
    release = Bosh::Template::Test::ReleaseDir.new(RELEASE_ROOT)
    job = release.job('blacksmith')
    template = job.template('config/blacksmith.conf')
    template.render(deep_merge(base, overrides))
  end

  # BASE_PROPERTIES with bosh.ca_cert removed.
  def base_without_ca
    BASE_PROPERTIES.merge('bosh' => BASE_PROPERTIES['bosh'].reject { |k, _| k == 'ca_cert' })
  end

  # Renders and parses the result as YAML.
  def render_conf_yaml(overrides = {})
    YAML.safe_load(render_conf(overrides))
  end
end

RSpec.configure { |c| c.include BlacksmithConfSpecHelpers }

RSpec.describe 'blacksmith.conf' do
  describe 'bosh.allow_http' do
    it 'renders false as a YAML boolean by default' do
      expect(render_conf_yaml['bosh']['allow_http']).to be(false)
    end

    it 'renders an override to true as a YAML boolean' do
      expect(render_conf_yaml('bosh' => { 'allow_http' => true })['bosh']['allow_http']).to be(true)
    end
  end

  describe 'bosh.ca_cert' do
    it 'fails the render without bosh.ca_cert and names it' do
      expect { render_conf({}, base_without_ca) }
        .to raise_error(RuntimeError, /bosh\.ca_cert/)
    end

    ['', '   ', " \n\t "].each do |blank|
      it "fails the render for #{blank.inspect} and names the property" do
        expect { render_conf('bosh' => { 'ca_cert' => blank }) }
          .to raise_error(RuntimeError, /bosh\.ca_cert.*required/m)
      end
    end

    it 'renders a set CA as the cacert value' do
      expect(render_conf_yaml['bosh']['cacert']).to eq(TEST_CA_PEM)
    end
  end

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

    it 'renders no credhub block and does not raise when no credhub property is set' do
      expect(render_conf_yaml).not_to have_key('credhub')
    end

    it 'renders no credhub block when cleanup is enabled and none of the four are set' do
      expect(render_conf_yaml('credhub' => { 'cleanup' => { 'enabled' => true } })).not_to have_key('credhub')
    end

    it 'renders a dry-run sweep by default when the connection is set' do
      credhub = render_conf_yaml('credhub' => connection)['credhub']
      expect(credhub['cleanup']['sweep']).to eq('dry-run')
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
      credhub = render_conf_yaml('credhub' => connection.merge('cleanup' => { 'sweep' => false }))['credhub']
      expect(credhub['cleanup']['sweep']).to eq('off')
    end

    it 'keeps the broker deployment first in the protected list' do
      credhub = render_conf_yaml('credhub' => connection.merge('cleanup' => { 'protected_deployments' => ['other-one'] }))['credhub']
      expect(credhub['cleanup']['protected_deployments']).to eq(['my-deployment', 'other-one'])
    end

    it 'puts the job deployment name first in the protected list by default' do
      expect(render_conf_yaml('credhub' => connection)['credhub']['cleanup']['protected_deployments'].first).to eq('my-deployment')
    end

    it 'renders cleanup disabled when the connection is set and cleanup is off' do
      credhub = render_conf_yaml('credhub' => connection.merge('cleanup' => { 'enabled' => false }))['credhub']
      expect(credhub).to include(connection)
      expect(credhub['cleanup']['enabled']).to eq(false)
    end

    it 'raises on a partial connection even when cleanup is disabled' do
      partial = connection.slice('url', 'ca_cert', 'client_secret').merge('cleanup' => { 'enabled' => false })
      expect { render_conf('credhub' => partial) }
        .to raise_error(RuntimeError, /credhub\.director_name/)
    end

    it 'renders no credhub block with cleanup disabled and no connection' do
      expect(render_conf_yaml('credhub' => { 'cleanup' => { 'enabled' => false } })).not_to have_key('credhub')
    end
  end

  describe 'certificates switches' do
    it 'defaults inventory on, rotation off, and patch in place off' do
      expect(render_conf_yaml['certificates']).to eq(
        'inventory' => { 'enabled' => true },
        'rotation' => { 'enabled' => false },
        'patch_in_place' => { 'enabled' => false },
      )
    end

    it 'renders rotation on when set' do
      certs = render_conf_yaml('certificates' => { 'rotation' => { 'enabled' => true } })['certificates']
      expect(certs['rotation']['enabled']).to eq(true)
      expect(certs['inventory']['enabled']).to eq(true)
      expect(certs['patch_in_place']['enabled']).to eq(false)
    end

    it 'renders inventory off and patch in place on when set' do
      certs = render_conf_yaml('certificates' => { 'inventory' => { 'enabled' => false }, 'patch_in_place' => { 'enabled' => true } })['certificates']
      expect(certs['inventory']['enabled']).to eq(false)
      expect(certs['patch_in_place']['enabled']).to eq(true)
    end

    %w[inventory rotation patch_in_place].each do |gate|
      it "raises when #{gate} is the string \"false\"" do
        expect { render_conf('certificates' => { gate => { 'enabled' => 'false' } }) }
          .to raise_error(RuntimeError, /certificates\.#{gate}\.enabled must be true or false, but it is "false"/)
      end
    end

    it 'raises when credhub cleanup enabled is the string "no"' do
      credhub = { 'url' => 'https://c:8844', 'ca_cert' => 'ca', 'client_secret' => 's', 'director_name' => 'd',
                  'cleanup' => { 'enabled' => 'no' } }
      expect { render_conf('credhub' => credhub) }
        .to raise_error(RuntimeError, /credhub\.cleanup\.enabled must be true or false, but it is "no"/)
    end
  end

  describe 'command switches' do
    it 'renders no commands block and no director_workers when unset' do
      conf = render_conf_yaml
      expect(conf).not_to have_key('commands')
      expect(conf['bosh']).not_to have_key('director_workers')
    end

    it 'renders commands enabled true and false' do
      expect(render_conf_yaml('commands' => { 'enabled' => true })['commands']).to eq('enabled' => true)
      expect(render_conf_yaml('commands' => { 'enabled' => false })['commands']).to eq('enabled' => false)
    end

    it 'renders allow_root true and false without touching enabled' do
      expect(render_conf_yaml('commands' => { 'allow_root' => true })['commands']).to eq('allow_root' => true)
      expect(render_conf_yaml('commands' => { 'allow_root' => false })['commands']).to eq('allow_root' => false)
    end

    it 'renders both switches together' do
      cmds = render_conf_yaml('commands' => { 'enabled' => false, 'allow_root' => true })['commands']
      expect(cmds).to eq('enabled' => false, 'allow_root' => true)
    end

    %w[enabled allow_root].each do |name|
      it "raises when commands.#{name} is the string \"false\"" do
        expect { render_conf('commands' => { name => 'false' }) }
          .to raise_error(RuntimeError, /commands\.#{name} must be true or false, but it is "false"/)
      end
    end

    it 'renders the credential key only when set' do
      expect(render_conf_yaml('commands' => { 'credential' => { 'key' => '' } })).not_to have_key('commands')
      cmds = render_conf_yaml('commands' => { 'credential' => { 'key' => 'k-1' } })['commands']
      expect(cmds).to eq('credential' => { 'key' => 'k-1' })
    end

    it 'treats a null director_workers as unset' do
      conf = render_conf_yaml('bosh' => { 'director_workers' => nil })
      expect(conf['bosh']).not_to have_key('director_workers')
    end

    it 'renders a valid director_workers' do
      expect(render_conf_yaml('bosh' => { 'director_workers' => 6 })['bosh']['director_workers']).to eq(6)
      expect(render_conf_yaml('bosh' => { 'director_workers' => 2 })['bosh']['director_workers']).to eq(2)
    end

    [0, 1, -3, 'four', 2.5, '4'].each do |bad|
      it "raises when director_workers is #{bad.inspect}" do
        expect { render_conf('bosh' => { 'director_workers' => bad }) }
          .to raise_error(RuntimeError, /bosh\.director_workers must be a whole number of 2 or more/)
      end
    end
  end
end
