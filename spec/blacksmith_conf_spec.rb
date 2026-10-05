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
end
