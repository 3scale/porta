# frozen_string_literal: true

require 'test_helper'

class Stats::Data::RequestsToApiTest < ActionDispatch::IntegrationTest

  def setup
    @provider_account = FactoryBot.create(:provider_account)
    @service          = @provider_account.default_service
    @plan             = FactoryBot.create(:simple_application_plan, issuer: @service)
    @buyer_account    = FactoryBot.create(:simple_buyer, provider_account: @provider_account)
    @application      = @buyer_account.buy!(@plan)

    host! @provider_account.self_domain
  end

  # Applications Usage

  # Access token

  test 'usage with access token' do
    member = FactoryBot.create(:member, account: @provider_account, admin_sections: ['monitoring'])
    token  = FactoryBot.create(:access_token, owner: member, scopes: ['stats'])
    params = { period: 'day', metric_name: 'hits', access_token: token.value }

    # token includes the right scope, member has the right permission, all services are accessible
    get "/stats/applications/#{@application.id}/usage.json", params: params
    assert_response :success

    token.scopes = ['finance']
    token.save!
    # token does not include the right scope
    get "/stats/applications/#{@application.id}/usage.json", params: params
    assert_response :forbidden

    token.scopes = ['stats']
    token.save!
    member.admin_sections = []
    member.save!
    # member does not have the right permission
    get "/stats/applications/#{@application.id}/usage.json", params: params
    assert_response :forbidden

    member.admin_sections = ['monitoring']
    member.save!
    User.any_instance.expects(:has_access_to_all_services?).returns(false).at_least_once
    # the service is not accessible for the member
    get "/stats/applications/#{@application.id}/usage.json", params: params
    assert_response :forbidden

    User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
    # the service is accessible for the member
    get "/stats/applications/#{@application.id}/usage.json", params: params
    assert_response :success
  end

  test 'summary with access token' do
    member = FactoryBot.create(:member, account: @provider_account, admin_sections: ['monitoring'])
    token  = FactoryBot.create(:access_token, owner: member, scopes: ['stats'])
    params = { period: 'day', metric_name: 'hits', access_token: token.value }

    get "/stats/applications/#{@application.id}/summary.json", params: params
    assert_response :success
  end

  # Provider key

  test 'respond on json for applications' do
    params = { period: 'day', metric_name: "hits", provider_key: @provider_account.api_key }
    get "/stats/applications/#{@application.id}/usage.json", params: params
    assert_response :success
    assert_content_type 'application/json'
  end

  test 'respond on xml for applications' do
    params = { period: 'day', metric_name: "hits", provider_key: @provider_account.api_key }
    get "/stats/applications/#{@application.id}/usage.xml", params: params
    assert_response :success
    assert_content_type 'application/xml'
  end

  test 'not returning change if asked' do
    params = { period: 'day', metric_name: "hits", provider_key: @provider_account.api_key, skip_change: 'false' }
    get "/stats/applications/#{@application.id}/usage.xml", params: params
    assert_response :success
    assert_content_type 'application/xml'
    refute_match 'change', @response.body
  end

  test 'not returning change by default' do
    params = { period: 'day', metric_name: "hits", provider_key: @provider_account.api_key }
    get "/stats/applications/#{@application.id}/usage.json", params: params
    assert_response :success
    refute data['change']
    assert_content_type 'application/json'
  end

  test 'returning change if asked' do
    params = { period: 'day', metric_name: "hits", provider_key: @provider_account.api_key, skip_change: 'false' }
    get "/stats/applications/#{@application.id}/usage.json", params: params
    assert_response :success
    assert data['change'], "#{data} should have change key"
    assert_content_type 'application/json'
  end

  test 'respond when missing params for applications' do
    params = { period: 'day', provider_key: @provider_account.api_key }
    get "/stats/applications/#{@application.id}/usage.xml", params: params
    assert_response :bad_request
    assert_content_type 'text/plain'
  end

  test 'response when application not found' do
    params = { period: 'day', metric_name: "hits", provider_key: @provider_account.api_key }
    get "/stats/applications/XXX/usage.json", params: params
    assert_response :not_found
    assert_content_type 'application/json'
    assert_equal '{"error":"Application not found"}', @response.body
  end

  test 'respond when provided with non-existent metric for applications' do
    params = { period: 'day', metric_name: "xxxx", provider_key: @provider_account.api_key }
    get "/stats/applications/#{@application.id}/usage.json", params: params
    assert_response :bad_request
    assert_content_type 'application/json'
    assert_equal '{"error":"metric xxxx not found"}', @response.body
  end


  # Services

  test 'respond on json for services' do
    params = { period: 'day', metric_name: "hits", provider_key: @provider_account.api_key }
    get "/stats/services/#{@service.id}/usage.json", params: params
    assert_response :success
    assert_content_type 'application/json'
  end

  test 'respond on json for services in negative timezone and very old times' do
    params = { period: 'month', since: '0150-12-01', timezone: 'Pacific Time (US & Canada)', metric_name: "hits", provider_key: @provider_account.api_key }
    get "/stats/services/#{@service.id}/usage.json", params: params
    assert_response :success
    assert_content_type 'application/json'

    # to trigger the shift > 0 conditions
    get "/stats/services/#{@service.id}/usage.json", params: params.merge(timezone: 'New Delhi')
    assert_response :success
    assert_content_type 'application/json'

    # to trigger the granularity == :month condition
    get "/stats/services/#{@service.id}/usage.json", params: params.merge(period: 'year')
    assert_response :success
    assert_content_type 'application/json'

    # to trigger both the shift > 0 conditions and granularity == :month
    get "/stats/services/#{@service.id}/usage.json", params: params.merge(period: 'year', timezone: 'New Delhi')
    assert_response :success
    assert_content_type 'application/json'
  end

  test 'respond on xml for services' do
    params = { period: 'day', metric_name: "hits", provider_key: @provider_account.api_key }
    get "/stats/services/#{@service.id}/usage.xml", params: params
    assert_response :success
    assert_content_type 'application/xml'
  end

  test 'respond when missing params for services' do
    params = { period: 'day', provider_key: @provider_account.api_key }
    get "/stats/services/#{@service.id}/usage.xml", params: params
    assert_response :bad_request
    assert_content_type 'text/plain'
  end

  test 'respond when provided with non-existent metric for services' do
    params = { period: 'day', metric_name: "xxxx", provider_key: @provider_account.api_key }
    get "/stats/services/#{@service.id}/usage.json", params: params
    assert_response :bad_request
    assert_content_type 'application/json'
    assert_equal '{"error":"metric xxxx not found"}', @response.body
  end

  test 'response when service not found' do
    params = { period: 'day', metric_name: "hits", provider_key: @provider_account.api_key }
    get "/stats/services/XXX/usage.json", params: params
    assert_response :not_found
    assert_content_type 'application/json'
    assert_equal '{"error":"Service not found"}', @response.body
  end

  private

  def data
    case @response.content_type
    when /xml/ then Hash.from_xml(@response.body)
    when /json/ then JSON.parse(@response.body)
    end
  end
end
