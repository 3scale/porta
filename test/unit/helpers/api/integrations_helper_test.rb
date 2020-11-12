require 'test_helper'

class Api::IntegrationsHelperTest < ActionView::TestCase
  test 'is_https? returns false for invalid urls, without throwing errors' do
    refute(is_https?('foo'))
    refute(is_https?(1))
    refute(is_https?(nil))
  end

  test 'print the proper proxy rule preview' do
    pattern = '/foo'
    backend_api = FactoryBot.create(:backend_api)
    FactoryBot.create(:proxy_rule, owner: backend_api, proxy: nil, pattern: pattern)
    backend_api_config = FactoryBot.create(:backend_api_config)
    backend_api_config.stubs(:path).returns('/')

    assert_equal pattern, proxy_rule_uri(backend_api_config.path, backend_api.proxy_rules.last)
  end

  class CurlCommand < ActionView::TestCase
    setup do
      @proxy = FactoryBot.create(:proxy)
    end

    attr_reader :proxy

    include ConfigBasedCommandTestHelpers

    test 'code with curl command' do
      create_proxy_config
      res = api_test_curl(proxy)
      assert_match %r(<code.+>curl &quot;.+user_key=USER_KEY&quot; </code>), res
    end

    test 'data-credentials' do
      @proxy = FactoryBot.create(:proxy, auth_user_key: 'my_cool_name_for_user_key')
      create_proxy_config
      res = api_test_curl(proxy)
      assert_match(/my_cool_name_for_user_key=USER_KEY/, res)
      assert_match(%{data-credentials="{&quot;user_key&quot;:&quot;USER_KEY&quot;}"}, res)
    end
  end
end
