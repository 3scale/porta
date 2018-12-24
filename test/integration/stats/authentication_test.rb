require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Stats::AuthenticationTest < ActionDispatch::IntegrationTest
  def setup
    @provider_account = Factory(:provider_account)
    @service = @provider_account.default_service

    host! @provider_account.admin_domain
  end

  test 'access allowed with authentication' do
    get "/stats/services/#{@service.id}/usage.json", period: 'day', metric_name: 'hits', provider_key: @provider_account.api_key
    assert_response :success
    assert_content_type 'application/json'

    token = FactoryBot.create(:access_token, owner: @provider_account.first_admin, scopes: ['stats'])
    get "/stats/services/#{@service.id}/usage.json", period: 'day', metric_name: 'hits', access_token: token.value
    assert_response :success
    assert_content_type 'application/json'
  end

  test 'access forbidden without authentication' do
    get "/stats/services/#{@service.id}/usage.json", :period => 'day', :metric_name => "hits"

    assert_response :forbidden
    assert_content_type 'application/json'
    assert_json 'status' => 'Forbidden'
  end

  # Regression test - DoubleRender error
  #
  # https://3scale.hoptoadapp.com/errors/9899473
  #
  test 'access forbidden without authentication and invalid format' do
    get "/stats/services/#{@service.id}/usage.INVALID", :period => 'day', :metric_name => "hits"

    assert_response 403
  end
end
