require 'test_helper'

class Api::IntegrationsHelperTest < ActionView::TestCase

  def setup
    @proxy = FactoryBot.create(:proxy, :service => FactoryBot.create(:service))
  end

  class ModelBasedCurlCommandTest < self
    test 'auth in query' do
      @proxy.update_attributes(credentials_location:  'query')
      res = api_test_curl(@proxy)
      assert_match(/user_key=USER_KEY/, res)
    end

    test 'user_key mode with customized param name' do
      @proxy.update_attributes(auth_user_key:  'my_cool_name_for_user_key')
      res = api_test_curl(@proxy)
      assert_match(/my_cool_name_for_user_key=USER_KEY/, res)
      assert_match(%{data-credentials="{&quot;user_key&quot;:&quot;USER_KEY&quot;}"}, res)
    end

    test 'auth in headers' do
      @proxy.update_attributes(credentials_location:  'headers')
      res = api_test_curl(@proxy)
      assert_match(/-H&#39;user_key: USER_KEY/, res) # 39 is ', 27 is escape
    end

    test 'auth basic' do
      @proxy.update_attributes(credentials_location: 'authorization')

      res = api_test_curl(@proxy)
      assert_match %r(http://USER_KEY@), res

      @proxy.service.update_attributes(backend_version: '2')
      @proxy.reload
      res = api_test_curl(@proxy)
      assert_match %r(http://APP_ID:APP_KEY@), res
    end

    test 'no double ?' do
      account = @proxy.service.account
      account.stubs(:provider_can_use?).returns(true)
      account.expects(:provider_can_use?).with(:api_as_product).returns(false).at_least_once
      @proxy.update_attributes(api_test_path: '/a?b=c')
      res = api_test_curl(@proxy)
      assert_match(/a\?b=c&/, res)
    end

    test 'empty api_test_path' do
      @proxy.update_attributes(api_test_path: nil)
      res = api_test_curl(@proxy)
      assert_match(/\?user/, res)
    end

    test 'build path from proxy_rules when api as product is enabled' do
      account = @proxy.service.account
      account.stubs(:provider_can_use?).returns(true)
      account.expects(:provider_can_use?).with(:api_as_product).returns(true).at_least_once

      @proxy.update_attributes(api_test_path: '/bar')
      FactoryBot.create(:proxy_rule, proxy: @proxy, pattern: '/foo', position: 1)
      res = api_test_curl(@proxy)
      assert_match(/\/foo\?/, res)
    end

    test 'build path from api_test_path when api as product is disabled' do
      account = @proxy.service.account
      account.stubs(:provider_can_use?).returns(true)
      account.expects(:provider_can_use?).with(:api_as_product).returns(false).at_least_once

      @proxy.update_attributes(api_test_path: '/bar')
      FactoryBot.create(:proxy_rule, proxy: @proxy, pattern: '/foo', position: 1)
      res = api_test_curl(@proxy)
      assert_match(/\/bar\?/, res)
    end

    test 'auth mode app_id and app_key' do
      @proxy.service.update_attributes(backend_version: '2')
      @proxy.update_attributes(credentials_location:  'query')
      res = api_test_curl(@proxy)
      assert_match(/&?app_key=APP_KEY/, res)
      assert_match(/&?app_id=APP_ID/, res)
    end

    test 'app_id and app_key mode with customized params name' do
      @proxy.service.update_attributes(backend_version: '2')
      @proxy.update_attributes(auth_app_id:  'id')
      @proxy.update_attributes(auth_app_key:  'p-a-s-s')
      res = api_test_curl(@proxy)
      assert_match(/id=APP_ID/, res)
      assert_match(/p-a-s-s=APP_KEY/, res)
    end
  end

  class ConfigBasedCurlCommandTest < self
    def setup
      super
    end

    attr_reader :proxy

    test 'auth in query' do
      create_proxy_config
      res = api_test_curl(proxy, config_based: true)
      assert_match(/user_key=USER_KEY/, res)
    end

    test 'auth in headers' do
      create_proxy_config(proxy: { credentials_location: 'headers' })
      res = api_test_curl(proxy, config_based: true)
      assert_match(/-H&#39;user_key: USER_KEY/, res) # 39 is ', 27 is escape
    end

    test 'auth basic' do
      create_proxy_config(proxy: { credentials_location: 'authorization' })

      res = api_test_curl(proxy, config_based: true)
      assert_match %r(https://USER_KEY@), res

      proxy.service.update_attributes(backend_version: '2')
      proxy.reload
      res = api_test_curl(proxy, config_based: true)
      assert_match %r(https://APP_ID:APP_KEY@), res
    end

    test 'user_key mode with customized param name' do
      create_proxy_config(proxy: { auth_user_key: 'my_cool_name_for_user_key' })
      res = api_test_curl(proxy, config_based: true)
      assert_match(/my_cool_name_for_user_key=USER_KEY/, res)
      assert_match(%{data-credentials="{&quot;user_key&quot;:&quot;USER_KEY&quot;}"}, res)
    end

    test 'no double ?' do
      Account.any_instance.stubs(:provider_can_use?).returns(true)
      Account.any_instance.expects(:provider_can_use?).with(:api_as_product).returns(false).at_least_once
      create_proxy_config(proxy: { api_test_path: '/a?b=c' })
      res = api_test_curl(proxy, config_based: true)
      assert_match(/a\?b=c&/, res)
    end

    test 'empty api_test_path' do
      create_proxy_config(proxy: { api_test_path: nil })
      res = api_test_curl(proxy, config_based: true)
      assert_match(/\?user/, res)
    end

    test 'build path from proxy_rules when api as product is enabled' do
      Account.any_instance.stubs(:provider_can_use?).returns(true)
      Account.any_instance.expects(:provider_can_use?).with(:api_as_product).returns(true).at_least_once
      create_proxy_config
      res = api_test_curl(proxy, config_based: true)
      assert_match(/\/foo\?/, res)
    end

    test 'build path from api_test_path when api as product is disabled' do
      Account.any_instance.stubs(:provider_can_use?).returns(true)
      Account.any_instance.expects(:provider_can_use?).with(:api_as_product).returns(false).at_least_once
      create_proxy_config
      res = api_test_curl(proxy, config_based: true)
      assert_match(/\/test\?/, res)
    end

    test 'auth mode app_id and app_key' do
      proxy.service.update_attributes(backend_version: '2')
      create_proxy_config
      res = api_test_curl(proxy, config_based: true)
      assert_match(/&?app_key=APP_KEY/, res)
      assert_match(/&?app_id=APP_ID/, res)
    end

    test 'app_id and app_key mode with customized params name' do
      proxy.service.update_attributes(backend_version: '2')
      create_proxy_config(proxy: { auth_app_id: 'id', auth_app_key: 'p-a-s-s' })
      res = api_test_curl(proxy, config_based: true)
      assert_match(/id=APP_ID/, res)
      assert_match(/p-a-s-s=APP_KEY/, res)
    end

    protected

    def proxy_config_content
      {
        proxy: {
          service_id: @proxy.service_id,
          endpoint: 'https://public-production.fake',
          sandbox_endpoint: 'https://public-staging.fake',
          auth_app_key: 'app_key',
          auth_app_id: 'app_id',
          auth_user_key: 'user_key',
          credentials_location: 'query',
          api_test_path: '/test',
          proxy_rules: [{ pattern: "/foo" }, { pattern: "/bar" }]
        }
      }
    end

    def create_proxy_config(patch = {})
      FactoryBot.create(:proxy_config, proxy: proxy, content: proxy_config_content.deep_merge(patch).to_json)
    end
  end

  class IsHttpTest < self
    test 'is_https? returns false for invalid urls, without throwing errors' do
      refute(is_https?('foo'))
      refute(is_https?(1))
      refute(is_https?(nil))
    end
  end
end
