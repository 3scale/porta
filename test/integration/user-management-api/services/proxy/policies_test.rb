require 'test_helper'

class Admin::Api::Services::Proxy::PoliciesTest < ActionDispatch::IntegrationTest

  def setup
    account  = FactoryGirl.create(:provider_account)
    @service = FactoryGirl.create(:simple_service, account: account)
    admin    = FactoryGirl.create(:admin, account: account)
    @token   = FactoryGirl.create(:access_token, owner: admin, scopes: 'account_management')

    host! account.admin_domain
  end

  def test_show
    proxy.policies_config = [{ 'name' => 'schema', 'version' => '1', 'configuration' => {} }]
    proxy.save!
    get admin_api_service_proxy_policies_path(valid_params)
    assert_match "{\"name\":\"schema\",\"version\":\"1\",\"configuration\":{}}", response.body
  end

  def test_show_forbidden
    rolling_updates_off
    get admin_api_service_proxy_policies_path(valid_params)
    assert_response :not_found
  end

  def test_update_without_errors
    put admin_api_service_proxy_policies_path(valid_params.merge(
      { proxy: { policies_config: [{'name' => 'alaska', 'version' => '1', 'configuration' => {}}].to_json }}))
    assert_match "{\"name\":\"alaska\",\"version\":\"1\",\"configuration\":{}}", response.body
    assert_response :success
    policies_config = proxy.reload.policies_config
        .map { |attrs| Proxy::PolicyConfig.new(attrs) }
        .select { |policy_config| policy_config.name == 'alaska' \
          && policy_config.version == '1' && policy_config.configuration == {} }

    assert_equal 1, policies_config.length
  end

  def test_update_json
    put admin_api_service_proxy_policies_path(valid_params.merge(
      { proxy: { policies_config: [{'name' => 'alaska', 'version' => '1', 'configuration' => { 'schema' => '1' }}] }}))
    assert_match "{\"name\":\"alaska\",\"version\":\"1\",\"configuration\":{\"schema\":\"1\"}}", response.body
    assert_response :success
  end

  def test_update_with_errors
    put admin_api_service_proxy_policies_path(valid_params.merge(
        { proxy: { policies_config: [{'name' => 'alaska'}].to_json }}))
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal ['can\'t be blank'], json_response.dig('policies_config', 0, 'errors', 'version')
    assert_equal ['can\'t be blank'], json_response.dig('policies_config', 0, 'errors', 'configuration')
  end

  def valid_params
    {
      service_id:   @service.id,
      access_token: @token.value,
      format:       :json
    }
  end

  attr_reader :service
  delegate :proxy, to: :service
end
