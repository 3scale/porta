require 'test_helper'

class Api::ProxyConfigsControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryGirl.create(:simple_provider)
    @service = FactoryGirl.create(:simple_service, account: @provider)
    @admin = FactoryGirl.create(:simple_admin, account: @provider, username: 'some-user')

    login_provider @provider, user: @admin
  end

  test 'listing configs' do
    config = FactoryGirl.create(:proxy_config, proxy: @service.proxy, user: @admin)

    get :index, service_id: @service

    assert_response :success

    assert_select 'td', text: 'some-user'
    assert_select 'a', text: "apicast-config-#{@service.parameterized_name}-#{config.environment}-#{config.version}.json"
  end

  test 'get config' do
    config = FactoryGirl.create(:proxy_config, proxy: @service.proxy, content: '{"foo":"bar"}')

    get :show, service_id: @service, id: config

    assert_response :success

    assert_equal '{"foo":"bar"}', response.body
  end
end
