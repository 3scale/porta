require 'test_helper'

class Api::IntegrationsHelperTest < ActionView::TestCase

  def setup
      @proxy = Factory(:proxy, :service => Factory(:service))
  end

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
    @proxy.update_attributes(api_test_path:  '/a?b=c')
    res = api_test_curl(@proxy)
    assert_match(/a\?b=c&/, res)
  end

  test 'empty api_test_path' do
    @proxy.update_attributes(api_test_path:  nil)
    res = api_test_curl(@proxy)
    assert_match(/\?user/, res)
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

  test 'is_https? returns false for invalid urls, without throwing errors' do
    refute(is_https?('foo'))
    refute(is_https?(1))
    refute(is_https?(nil))
  end

end
