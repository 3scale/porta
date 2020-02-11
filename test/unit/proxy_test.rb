require 'test_helper'

class ProxyTest < ActiveSupport::TestCase
  def setup
    @proxy = FactoryBot.create(:simple_proxy, api_backend: nil)
    @proxy.update_attributes!(apicast_configuration_driven: false)
    @service = @proxy.service
    @account = @service.account
  end

  def teardown
    ::WebMock.reset!
  end

  class NoContextNecessary < ActiveSupport::TestCase

    def test_policies_config_structure
      service = FactoryBot.create(:simple_service)
      proxy = Proxy.new(policies_config: [{ name: '1', version: 'a', configuration: {} }], service: service)
      assert proxy.valid?

      proxy.policies_config = [{ name: '1' }]
      refute proxy.valid?
      assert_match 'version can\'t be blank', proxy.errors.full_messages.to_sentence
      assert_match 'configuration can\'t be blank', proxy.errors.full_messages.to_sentence
    end

    def test_policies_config
      proxy = Proxy.new(policies_config: "[{\"data\":{\"request\":\"1\",\"config\":\"123\"}}]")
      assert_equal proxy.policies_config.first, { "data" => { "request" => "1", "config" => "123" }}
      assert_equal 2, proxy.policies_config.count
      # it should not add default policy again
      assert_equal 2, proxy.policies_config.count
    end

    def test_policy_chain
      rolling_updates_on
      raw_config = [{
                      name: 'cors',
                      humanName: 'Cors Proxy',
                      version: '0.0.1',
                      description: 'Cors proxy for service 1',
                      configuration: {foo: 'bar'},
                      enabled: true,
                      id: '1'
                    },
                    {
                      name: 'cors',
                      humanName: 'Cors Proxy',
                      version: '0.0.1',
                      description: 'Cors proxy for service 2',
                      configuration: {baz: 'fu'},
                      enabled: false,
                      id: '2'
                    },
                    {
                      name: 'cors',
                      humanName: 'Cors Proxy',
                      version: '0.0.1',
                      description: 'Cors proxy for service 3',
                      configuration: {hello: 'Aloha'},
                      enabled: true,
                      id: '3'
                    }]
      service = Service.new
      proxy = Proxy.new(policies_config: raw_config.to_json, service: service)
      proxy.stubs(:account).returns(FactoryBot.build_stubbed(:simple_provider))
      policy_chain =  [
        {'name' => 'cors', 'version' => '0.0.1', 'configuration' => {'foo' => 'bar'}},
        {'name' => 'cors', 'version' => '0.0.1', 'configuration' => {'hello' => 'Aloha'}},
        {'name' => 'apicast', 'version' => 'builtin', 'configuration' => {}}
      ]

      assert_equal policy_chain, proxy.policy_chain
    end


    def test_policy_chain_with_backend_apis
      rolling_updates_on

      account = FactoryBot.create(:simple_provider)
      service = FactoryBot.create(:simple_service, :with_default_backend_api, account: account)
      null_backend_api = FactoryBot.create(:backend_api, account: account, private_endpoint: 'https://foo.baz')
      null_backend_api.update_columns(private_endpoint: '')
      backend_api0 = service.backend_apis.first
      backend_api1 = FactoryBot.create(:backend_api, account: account, private_endpoint: 'https://private-1.example.com')
      backend_api2 = FactoryBot.create(:backend_api, account: account, private_endpoint: 'https://private-2.example.com')
      FactoryBot.create(:backend_api_config, path: '/null', backend_api: null_backend_api, service: service)
      FactoryBot.create(:backend_api_config, path: '/foo', backend_api: backend_api1, service: service)
      FactoryBot.create(:backend_api_config, path: '/foo/bar', backend_api: backend_api2, service: service)
      policy_chain =  [
        {"name"=>"routing", "version"=>"builtin", "enabled"=>true,
          "configuration"=>{
            "rules"=>[
              {"url"=>"https://private-2.example.com:443", "owner_id"=>backend_api2.id, "owner_type" => "BackendApi", "condition"=>{"operations"=>[{"match"=>"path", "op"=>"matches", "value"=>"/foo/bar/.*|/foo/bar/?"}]}, 'replace_path'=>"{{original_request.path | remove_first: '/foo/bar'}}"},
              {"url"=>"https://private-1.example.com:443", "owner_id"=>backend_api1.id, "owner_type" => "BackendApi", "condition"=>{"operations"=>[{"match"=>"path", "op"=>"matches", "value"=>"/foo/.*|/foo/?"}]}, 'replace_path'=>"{{original_request.path | remove_first: '/foo'}}"},
              {"url"=>"https://echo-api.3scale.net:443", "owner_id"=>backend_api0.id, "owner_type" => "BackendApi", "condition"=>{"operations"=>[{"match"=>"path", "op"=>"matches", "value"=>"/.*"}]}}
            ]
          }
        },
        {"name"=>"apicast", "version"=>"builtin", "configuration"=>{}}
      ]

      assert_equal policy_chain, service.proxy.policy_chain
    end


    def test_authentication_method
      proxy = Proxy.new(authentication_method: 'oidc', service: Service.new)
      assert_equal 'oidc', proxy.authentication_method

      proxy_2 = Proxy.new(service: Service.new(backend_version: 'ouath'))
      assert_equal 'ouath', proxy_2.authentication_method

      assert_nil Proxy.new.authentication_method
    end

    def test_set_sandbox_endpoint_callback
      Proxy.any_instance.expects(:set_sandbox_endpoint).at_least_once
      FactoryBot.create(:simple_proxy)
    end

    def test_set_production_endpoint_callback
      Proxy.any_instance.expects(:set_production_endpoint).at_least_once
      FactoryBot.create(:simple_proxy)
    end

    def test_endpoint_validation
      service = FactoryBot.create(:simple_service)
      proxy = Proxy.new(service: service, apicast_configuration_driven: true)
      assert_equal proxy, service.proxy
      assert proxy.save!

      service.deployment_option = 'hosted'
      assert_valid proxy

      service.deployment_option = 'self_managed'
      assert_valid proxy

      service.deployment_option = 'plugin_ruby'
      assert_valid proxy
    end

    def test_sandbox_endpoint_validation
      service = FactoryBot.create(:simple_service, deployment_option: 'self_managed')
      proxy = Proxy.new(service: service, apicast_configuration_driven: true)

      assert proxy.valid?

      proxy.staging_endpoint = ''

      assert proxy.valid?
    end

    def test_endpoints_on_create
      service = FactoryBot.create(:simple_service, deployment_option: 'hosted')
      proxy = Proxy.create!(service: service, apicast_configuration_driven: true)

      assert proxy.staging_endpoint
      assert proxy.production_endpoint
    end

    def test_deployable
      assert_predicate Service.new(deployment_option: 'hosted').build_proxy, :deployable?
      assert_predicate Service.new(deployment_option: 'self_managed').build_proxy, :deployable?
      assert_predicate Service.new(deployment_option: 'service_mesh_istio').build_proxy, :deployable?

      refute_predicate Service.new(deployment_option: 'plugin_ruby').build_proxy, :deployable?
      refute_predicate Service.new(deployment_option: 'plugin_perl').build_proxy, :deployable?
    end
  end

  def test_apicast_configuration_driven
    @proxy.provider.stubs(:provider_can_use?).with(:apicast_v1).returns(true)
    @proxy.provider.stubs(:provider_can_use?).with(:apicast_v2).returns(true)

    @proxy.apicast_configuration_driven = true
    assert @proxy.apicast_configuration_driven

    @proxy.apicast_configuration_driven = false
    refute @proxy.apicast_configuration_driven

    @proxy.provider.stubs(:provider_can_use?).with(:apicast_v1).returns(false)
    assert @proxy.apicast_configuration_driven
  end


  def test_deploy_service_mesh_integration
    @proxy.provider.stubs(:provider_can_use?).with(:apicast_v1).returns(true)
    @proxy.provider.stubs(:provider_can_use?).with(:apicast_v2).returns(true)
    @proxy.provider.stubs(:provider_can_use?).with(:service_mesh_integration).returns(true)
    @proxy.stubs(:deployment_option).returns('service_mesh_istio')
    @proxy.expects(:deploy_v2).returns(true)
    @proxy.expects(:deploy_production_v2).returns(true)
    assert @proxy.deploy!
  end

  def test_deploy_production
    @proxy.assign_attributes(apicast_configuration_driven: true)
    @proxy.expects(:deploy_production_v2)
    @proxy.deploy_production

    @proxy.assign_attributes(apicast_configuration_driven: false, api_test_success: true)
    @account.expects(:deploy_production_apicast)
    @proxy.deploy_production
  end

  test 'hosts' do
    @proxy.endpoint = 'http://foobar.example.com:3000/path'
    @proxy.sandbox_endpoint = 'http://example.com:8080'

    Proxy.stubs(:config).returns(
      sandbox_endpoint: 'http://sandbox.example.com',
      default_production_endpoint: 'http://hosted.example.com'
    )

    assert_equal %W(foobar.example.com example.com), @proxy.hosts
  end

  test 'hosts with invalid urls' do
    @proxy.endpoint = 'some#invalid /host'
    @proxy.sandbox_endpoint = '$other invalid host'
    Proxy.stubs(:config).returns({})

    assert_equal %w(localhost), @proxy.hosts

    @proxy.sandbox_endpoint = 'http://example.com'

    assert_equal %w(localhost example.com), @proxy.hosts
  end

  test 'hosts comply with rfc 1035' do
    @proxy.endpoint = 'http://this-hostname-label-is-longer-than-63-chars-which-is-not-allowed-according-to-rfc-1035.com:3000/'
    @proxy.sandbox_endpoint = 'http://short-labels-are-ok.com:8080'
    refute @proxy.valid?
    assert @proxy.errors[:endpoint].any?
    refute @proxy.errors[:sandbox_endpoint].any?
  end

  test 'backend' do
    proxy_config = System::Application.config.three_scale.sandbox_proxy
    proxy_config.stubs(backend_scheme: 'https', backend_host: 'example.net:4400')
    assert_equal({ endpoint: 'https://example.net:4400', host: 'example.net' }, @proxy.backend)
  end

  test "proxy_enabled makes sure there's at least 1 proxy rule" do
    @proxy.api_backend = 'https://example.org:3'
    @proxy.save!
    assert_equal 1, @proxy.proxy_rules.size
  end

  test 'api_backend defaults to nil if there is no backend api' do
    assert_nil @proxy.api_backend
  end

  test 'proxy api backend formats ok' do
    %w[http://example.org:9 https://example.org:3].each do |endpoint|
      @proxy.api_backend = endpoint
      assert @proxy.valid?, @proxy.errors.full_messages.to_sentence
    end
  end

  test 'proxy api backend with base path' do
    @account.stubs(:provider_can_use?).with(:apicast_v1).returns(true)
    @account.stubs(:provider_can_use?).with(:apicast_v2).returns(true)
    @account.expects(:provider_can_use?).with(:proxy_private_base_path).at_least_once.returns(false)
    @account.expects(:provider_can_use?).with(:api_as_product).at_least_once.returns(false)
    backend_api = @proxy.backend_api
    backend_api.stubs(account: @account)
    @proxy.api_backend = 'https://example.org:3/path'
    refute @proxy.valid?
    assert_equal [@proxy.errors.generate_message(:api_backend, :invalid)], @proxy.errors.messages[:api_backend]

    @account.expects(:provider_can_use?).with(:proxy_private_base_path).at_least_once.returns(true)
    @proxy.api_backend = 'https://example.org:3/path'
    assert @proxy.valid?
  end

  test 'hostname_rewrite_for_sandbox' do
    @proxy.api_backend = 'https://echo-api.3scale.net:443'
    assert_equal 'echo-api.3scale.net', @proxy.hostname_rewrite_for_sandbox

    @proxy.hostname_rewrite = 'my-own.api.example.net'
    assert_equal 'my-own.api.example.net', @proxy.hostname_rewrite_for_sandbox

    # this is actually an invalid state and should not appear
    @proxy.api_backend = nil
    @proxy.hostname_rewrite = ''
    assert_equal 'none', @proxy.hostname_rewrite_for_sandbox
  end

  test 'oauth login url formats ok' do
    @proxy.api_backend = "https://example.org:89"
    @proxy.secret_token = "lskdjfkljdsf"
    %w[https://example.net?baz https://www.example.org localhost].each do |login_url|
      @proxy.oauth_login_url = login_url
      assert @proxy.valid?, "#{@proxy.errors.full_messages.to_sentence} - #{login_url}"
    end
  end

  test 'oauth login url formats invalid' do
    ['lalal dsa' , 'https://fdsa --fdsa', "foo\nbar", "'", '"',
     "https://example.org?scope=fdsa","https://example.org?state=fdsa",
     'https://example.org?tok%0x3dfoo', "https://example.org?tok=fdsa",
     "http://www.foo.example.net", "foo"].each do |login_url|
      @proxy.oauth_login_url = login_url
      @proxy.valid?
      assert @proxy.errors[:oauth_login_url], "no errors found on - #{login_url}".presence
    end
  end

  test 'api_test_path formats valid' do
    [  '/', '/i/m/a/lumberjack/42', '/~stuff', '/!not_-here']. each do |path|
      @proxy.api_test_path = path
      @proxy.valid?
      assert_empty @proxy.errors[:api_test_path], "errors found on - #{path}"
    end
  end

  test 'api_test_path formats invalid' do
    [ "http://example.org:32/fdsa" ].each do |path|
      @proxy.api_test_path = path
      @proxy.valid?
      assert @proxy.errors[:api_test_path], "errors not found on - #{path}".presence
    end
  end

  test 'proxy api backend formats invalid' do
    %w[example.org:9 fdsfas ssh://example.org:39 http://example.org:32/fdsa?a=1].each do |endpoint|
      @proxy.api_backend = endpoint
      refute @proxy.valid?
      assert_equal [@proxy.errors.generate_message(:api_backend, :invalid)], @proxy.errors.messages[:api_backend]
    end

    %w[http://localhost/ https://127.0.0.1 http://127.10.0.50].each do |endpoint|
      @proxy.api_backend = endpoint
      refute @proxy.valid?
      assert_equal [@proxy.errors.generate_message(:api_backend, :protected_domain)], @proxy.errors.messages[:api_backend]
    end
  end

  test '#endpoint_port' do
    proxy = FactoryBot.build_stubbed(:proxy)

    proxy.endpoint = nil
    assert_equal 80, proxy.endpoint_port

    proxy.endpoint = ''
    assert_equal 80, proxy.endpoint_port

    proxy.endpoint = 'foo bar invalid'
    assert_equal 80, proxy.endpoint_port

    proxy.endpoint = 'http://example.com/foo'
    assert_equal 80, proxy.endpoint_port

    proxy.endpoint = 'http://example.com:8080/foo'
    assert_equal 8080, proxy.endpoint_port

    proxy.endpoint = 'https://example.com/bar'
    assert_equal 443, proxy.endpoint_port

    proxy.endpoint = 'https://example.com:4433/bar'
    assert_equal 4433, proxy.endpoint_port
  end

  test 'proxy api backend auto port 80' do
    endpoint = 'http://example.org'
    @proxy.api_backend = endpoint
    @proxy.update_attributes endpoint: endpoint
    @proxy.secret_token = '123'
    @proxy.valid?

    assert @proxy.api_backend = 'http://example.org:80'
    assert @proxy.errors[:api_backend].blank?, "no api_backend errors found on - #{endpoint}"
  end

  test 'proxy api backend auto port 443' do
    endpoint = 'https://example.org'
    @proxy.api_backend = endpoint
    @proxy.update_attributes endpoint: endpoint
    @proxy.secret_token = '123'
    @proxy.valid?

    assert @proxy.api_backend = 'https://example.org:443'
    assert @proxy.errors[:api_backend].blank?, "no api_backend errors found on - #{endpoint}"
  end

  test 'proxy_endpoint is unique' do
    @proxy.update_attributes(endpoint: 'http://foo:80', api_backend: 'http://A:1', secret_token: 'fdsa')
    p2 = FactoryBot.create(:proxy, endpoint: 'http://foo:80', service: @service, api_backend: 'http://B:1', secret_token: 'fdsafsda')
  end

  test 'credentials names should allow good params' do
    m = FactoryBot.create(:metric, service: @service)

    %W[ foo bar-baz bar_baz].each do |w|
      @proxy.auth_app_id = w
      @proxy.auth_user_key= w
      @proxy.auth_app_key = w

      # to trigger the validations
      @proxy.valid?

      assert @proxy.errors[:auth_app_id].blank?
      assert @proxy.errors[:auth_user_key].blank?
      assert @proxy.errors[:auth_app_key].blank?
    end
  end

  test 'credentials names cannot have strange params' do
    m = FactoryBot.create(:metric, service: @service)

    %W|foo/bar {fdsa} fda [fdsa]|.each do |w|
      @proxy.auth_app_id = w
      @proxy.auth_user_key= w
      @proxy.auth_app_key = w

      @proxy.valid?

      assert @proxy.errors[:auth_app_id],   "auth_app_id".presence
      assert @proxy.errors[:auth_user_key], "auth_user_key".presence
      assert @proxy.errors[:auth_app_key],  "auth_app_key".presence
    end
  end

  test 'sandbox_endpoint set on creation' do
    assert_match %r{^https://}, @proxy.sandbox_endpoint
  end

  test 'api_test_path' do
    assert_equal '/', @proxy.api_test_path
  end

  test 'protected domains' do
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('production'))
    %W(localhost 127.0.0.1).each do |b|
      @proxy.api_backend = "http://#{b}:80"
      @proxy.valid?
      assert @proxy.errors[:api_backend],  "#{b} is protected".presence
    end
  end

  test 'allowed domains' do
    Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new('production'))
    %W(api.example.net).each do |b|
      @proxy.update_attributes(api_backend: "http://#{b}:80")
      assert @proxy.errors[:api_backend].blank?
    end
  end

  test 'sandbox_deployed? when last proxy log entry says so' do
    proxy = FactoryBot.create(:proxy, created_at: Time.now)
    refute proxy.sandbox_deployed?
    FactoryBot.create(:proxy_log, provider: proxy.service.account, status: 'Deployed successfully.', created_at: Time.now - 1.minute)
    refute proxy.sandbox_deployed?
    FactoryBot.create(:proxy_log, provider: proxy.service.account, status: 'Deployed successfully.', created_at: Time.now + 1.minute)
    assert proxy.sandbox_deployed?
    FactoryBot.create(:proxy_log, provider: proxy.service.account, status: 'Deploy failed.', created_at: Time.now + 2.minutes)
    refute proxy.sandbox_deployed?
  end

  test 'send_api_test_request!' do
    proxy = FactoryBot.create(:proxy, api_test_path: '/v1/word/stuff.json',
                                      secret_token: '123')
    proxy.update!(api_backend: "http://api_backend.#{ThreeScale.config.superdomain}:80",
                                      sandbox_endpoint: 'http://proxy:80')
    stub_request(:get, 'http://proxy/v1/word/stuff.json?user_key=USER_KEY')
        .to_return(status: 201, body: '', headers: {})

    analytics.expects(:track).with('Sandbox Proxy Test Request', has_entries(success: true, uri: 'http://proxy/v1/word/stuff.json', status: 201))
    assert proxy.send_api_test_request!
  end

  test 'send_api_test_request! with oauth' do
    proxy = FactoryBot.create(:proxy,
                                      api_backend: "http://api_backend.#{ThreeScale.config.superdomain}:80",
                                      sandbox_endpoint: 'http://proxy:80',
                                      api_test_path: '/v1/word/stuff.json',
                                      secret_token: '123')
    proxy.service.backend_version = 'oauth'
    proxy.api_test_success = true
    proxy.send_api_test_request!

    assert_nil proxy.api_test_success
  end

  test 'save_and_deploy' do
    proxy = FactoryBot.build(:proxy,
                              api_backend: 'http://example.com',
                              api_test_path: '/path',
                              apicast_configuration_driven: false)
    ::ProxyDeploymentV1Service.any_instance.expects(:deploy).with(proxy).returns(true)

    analytics.expects(:track).with('Sandbox Proxy Deploy', success: true)
    analytics.expects(:track).with('Sandbox Proxy updated',
                                   api_backend: 'http://example.com:80',
                                   api_test_path: '/path',
                                   success: true)
    analytics.expects(:track).with('APIcast Hosted Version Change', {enabled: false, service_id: proxy.service_id, deployment_option: 'hosted'})
    Logic::RollingUpdates.stubs(skipped?: true)

    assert proxy.save_and_deploy
    assert proxy.persisted?
  end

  test 'authentication_params_for_proxy' do
    @proxy.service.update_attribute(:backend_version, '1')
    assert_equal({ 'user_key' => 'USER_KEY' }, @proxy.reload.authentication_params_for_proxy)

    @proxy.update_attribute(:auth_user_key, 'my-auth')
    assert_equal({ 'my-auth' => 'USER_KEY' }, @proxy.authentication_params_for_proxy)
    assert_equal({ 'user_key' => 'USER_KEY' }, @proxy.authentication_params_for_proxy(original_names: true))

    @proxy.service.update_attribute(:backend_version, '2')
    assert_equal({"app_id"=>"APP_ID", "app_key"=>"APP_KEY"}, @proxy.reload.authentication_params_for_proxy)
  end

  def test_set_correct_endpoints
    @proxy.service.deployment_option = 'self_managed'
    @proxy.set_correct_endpoints
    assert_nil @proxy.endpoint
    @proxy.service.deployment_option = 'ruby_plugin'
    @proxy.set_correct_endpoints
    assert_nil @proxy.endpoint

    @proxy.service.deployment_option = 'hosted'
    @proxy.set_correct_endpoints
    assert_not_nil @proxy.endpoint
    @proxy.service.deployment_option = 'ruby_plugin'
    @proxy.set_correct_endpoints
    assert_not_nil @proxy.endpoint

    @proxy.service.deployment_option = 'whatever-non-existing'
    @proxy.set_correct_endpoints
    assert_nil @proxy.set_correct_endpoints
    assert_not_nil @proxy.endpoint
  end

  test 'publishing events' do
    EventStore::Repository.stubs(raise_errors: true)

    proxy_changed_events = EventStore::Repository.adapter.where(event_type: 'OIDC::ProxyChangedEvent')

    assert_difference proxy_changed_events.method(:count) do
      @proxy.service.backend_version = 'oauth'
      @proxy.save!
    end

    assert_difference proxy_changed_events.method(:count) do
      @proxy.oidc_issuer_endpoint = 'http://example.com'
      @proxy.oidc_issuer_type = 'keycloak'
      @proxy.save!
    end
  end

  test 'oidc_configuration standard flow enabled by default' do
    assert_instance_of OIDCConfiguration, @proxy.oidc_configuration
    assert @proxy.oidc_configuration.standard_flow_enabled
    refute @proxy.oidc_configuration.implicit_flow_enabled
    refute @proxy.oidc_configuration.service_accounts_enabled
    refute @proxy.oidc_configuration.direct_access_grants_enabled

    @proxy.oidc_configuration.direct_access_grants_enabled = true
    @proxy.save!
    assert Proxy.find(@proxy.id).oidc_configuration.direct_access_grants_enabled
  end

  test 'find policy config' do
    refute @proxy.find_policy_config_by(name: 'my-policy', version: '1.0.0')
    refute @proxy.find_policy_config_by(name: 'my-other-policy', version: '0.5.0')

    policy_config1 = { name: 'my-policy', version: '1.0.0', configuration: {}, enabled: true }.stringify_keys
    policy_config2 = { name: 'my-other-policy', version: '0.5.0', configuration: {}, enabled: false }.stringify_keys

    @proxy.policies_config = [policy_config1, policy_config2].map { |attr| Proxy::PolicyConfig.new(attr) }
    @proxy.save!
    @proxy.reload

    assert_equal policy_config1, @proxy.find_policy_config_by(name: 'my-policy', version: '1.0.0')
    assert_equal policy_config2, @proxy.find_policy_config_by(name: 'my-other-policy', version: '0.5.0')
  end

  test 'domain changes events on update of hosted proxy' do
    @proxy.service.deployment_option = 'hosted'

    Domains::ProxyDomainsChangedEvent.expects(:create).with(@proxy).once

    @proxy.update_attributes(staging_endpoint: 'http://example.com')
  end

  test 'domain changes events on update of self managed proxy' do
    @proxy.service.deployment_option = 'self_managed'

    Domains::ProxyDomainsChangedEvent.expects(:create).with(@proxy).once

    @proxy.update_attributes(staging_endpoint: 'http://example.com')
  end

  test 'domain changes events on destroy of hosted proxy' do
    @proxy.service.deployment_option = 'hosted'

    Domains::ProxyDomainsChangedEvent.expects(:create).with(@proxy).once

    @proxy.destroy
  end

  test 'domain changes events on destroy of self managed' do
    @proxy.service.deployment_option = 'self_managed'

    Domains::ProxyDomainsChangedEvent.expects(:create).with(@proxy).once

    @proxy.destroy
  end

  def analytics
    ThreeScale::Analytics::UserTracking.any_instance
  end

  test 'affecting change' do
    refute ProxyConfigAffectingChange.find_by(proxy_id: @proxy.id)
    @proxy.affecting_change_history
    assert ProxyConfigAffectingChange.find_by(proxy_id: @proxy.id)
  end

  test '#pending_affecting_changes?' do
    proxy = FactoryBot.create(:simple_proxy, api_backend: nil)
    proxy.affecting_change_history.touch

    # no existing config for staging (sandbox)
    refute proxy.pending_affecting_changes?

    Timecop.travel(1.second.from_now) do
      FactoryBot.create(:proxy_config, proxy: proxy, environment: :sandbox)

      # latest config is ahead of affecting change record
      refute proxy.pending_affecting_changes?

      proxy.affecting_change_history.touch

      # latest config is behind of affecting change record
      assert proxy.pending_affecting_changes?
    end
  end

  test '#affecting_change_history with fibers' do
    class ProxyWithFiber < ::Proxy
      def create_proxy_config_affecting_change(*)
        Fiber.yield
        super
      end
    end

    service = FactoryBot.create(:simple_service)
    proxy = ProxyWithFiber.find(service.proxy.id)

    f1 = Fiber.new { proxy.affecting_change_history }
    f2 = Fiber.new { proxy.affecting_change_history }

    f1.resume
    assert_nothing_raised(ActiveRecord::RecordNotUnique) do
      f2.resume
      f1.resume
      f2.resume
    end
    assert_equal 1, ProxyConfigAffectingChange.where(proxy: proxy).count
  end

  class ProxyConfigAffectingChangesTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    test 'proxy config affecting changes on create' do
      proxy = FactoryBot.build(:simple_proxy, api_backend: nil)
      # Proxy creation itself is not an affecting change...
      ProxyConfigs::AffectingObjectChangedEvent.expects(:create_and_publish!).with(proxy, proxy).never
      # ...but creation of first default proxy rule ('/') is
      ProxyConfigs::AffectingObjectChangedEvent.expects(:create_and_publish!).with(proxy, instance_of(ProxyRule))
      proxy.save!
    end

    test 'proxy config affecting changes on update' do
      provider = FactoryBot.create(:simple_provider)
      service = FactoryBot.create(:simple_service, account: provider)
      proxy = service.proxy

      ProxyConfigs::AffectingObjectChangedEvent.expects(:create_and_publish!).with(proxy, proxy).twice

      proxy.update_attributes(policies_config: [{ name: '1', version: 'b', configuration: {} }])
      proxy.update_attributes(deployed_at: Time.utc(2019, 9, 26, 12, 20))

      # A stale update is not an affecting change
      proxy.update_attributes(updated_at: Time.utc(2019, 9, 26, 12, 20))
    end
  end

  class StaleObjectErrorTest < ActiveSupport::TestCase
    test 'proxy does not raise stale object error on concurrent touch' do
      class ProxyWithFiber < ::Proxy
        def update_attributes(*)
          Fiber.yield
          super
        end
      end

      proxy_id = FactoryBot.create(:proxy).id

      fiber_update = Fiber.new { ProxyWithFiber.find(proxy_id).update_attributes(error_auth_failed: 'new auth error msg') }
      fiber_touch = Fiber.new { Proxy.find(proxy_id).touch }

      fiber_update.resume
      assert_nothing_raised(ActiveRecord::StaleObjectError) do
        fiber_touch.resume
        fiber_update.resume
      end
    end
  end
end
