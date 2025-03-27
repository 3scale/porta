# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Services::Proxy::PoliciesTest < ActionDispatch::IntegrationTest
  # hardcoding default policy hash to make sure changes to Proxy::PolicyConfig are being tested
  DEFAULT_POLICY = {"name"=>"apicast", "version"=>"builtin", "configuration"=>{}, "enabled"=>true}.freeze

  def setup
    account  = FactoryBot.create(:provider_account)
    @service = FactoryBot.create(:simple_service, account: account)
    admin    = FactoryBot.create(:admin, account: account)
    @token   = FactoryBot.create(:access_token, owner: admin, scopes: 'account_management')

    host! account.internal_admin_domain
  end

  def test_show
    example_policy = { 'name' => 'schema', 'version' => '1', 'configuration' => {} }
    proxy.policies_config = [example_policy]
    proxy.save!
    get admin_api_service_proxy_policies_path(valid_params)
    assert_equal JSON.parse(response.body)["policies_config"], [example_policy, DEFAULT_POLICY]
  end

  def test_show_default
    get admin_api_service_proxy_policies_path(format: :json, **valid_params)
    assert_response :success
    assert_equal JSON.parse(response.body), {"policies_config"=>[DEFAULT_POLICY]}
  end

  def test_update_without_errors
    example_policy = {'name' => 'alaska', 'version' => '1', 'configuration' => {}}
    put admin_api_service_proxy_policies_path(valid_params.merge({ proxy: { policies_config: [example_policy].to_json }}))
    assert_response :success

    get admin_api_service_proxy_policies_path(**valid_params)
    assert_response :success
    assert_equal JSON.parse(response.body)["policies_config"], [example_policy, DEFAULT_POLICY]
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

  def test_invalid_policies_config
    put admin_api_service_proxy_policies_path(valid_params.merge({ proxy: { policies_config: { name: 'echo '} }}))
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal ['can\'t be blank'], json_response.dig('policies_config', 0, 'errors', 'version')
    assert_equal ['can\'t be blank'], json_response.dig('policies_config', 0, 'errors', 'configuration')
  end

  def test_invalid_json_policies_config
    put admin_api_service_proxy_policies_path(valid_params.merge({ proxy: { policies_config: { name: 'echo '}.to_json }}))
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

  class MemberPermissionsTest < ActionDispatch::IntegrationTest

    attr_reader :service, :another_service, :access_token, :member

    def setup
      @provider = FactoryBot.create(:provider_account)
      @service = @provider.default_service
      @another_service = FactoryBot.create(:simple_service, account: @provider)
      @member = FactoryBot.create(:active_user, account: @provider, role: :member)
      @access_token = FactoryBot.create(:access_token, owner: @member, scopes: %w[policy_registry]).value

      host! @provider.external_admin_domain
    end

    test 'member with no policy registry or plans permission' do
      permissions = AdminSection.sections - %i[policy_registry plans]
      member.update(allowed_sections: permissions)

      get admin_api_service_proxy_policies_path(service, access_token: access_token, format: :json)

      assert_forbidden
    end

    test 'member with no services' do
      member.update(allowed_sections: :policy_registry, allowed_service_ids: [])

      get admin_api_service_proxy_policies_path(service, access_token: access_token, format: :json)

      assert_not_found
    end

    test 'member with access to a wrong service' do
      member.update(allowed_sections: :policy_registry, allowed_service_ids: [another_service.id])

      get admin_api_service_proxy_policies_path(service, access_token: access_token, format: :json)

      assert_not_found
    end

    test 'correct member permissions but wrong token scope' do
      member.update(allowed_sections: :policy_registry, allowed_service_ids: [service.id])
      new_token = FactoryBot.create(:access_token, owner: @member, scopes: %w[stats cms finance]).value

      get admin_api_service_proxy_policies_path(service, access_token: new_token, format: :json)

      assert_forbidden
    end

    test 'correct member permissions with invalid scope' do
      member.update(allowed_sections: :policy_registry, allowed_service_ids: [service.id])
      new_token = FactoryBot.create(:access_token, owner: member.reload, scopes: %w[account_management]).value

      get admin_api_service_proxy_policies_path(service, access_token: new_token, format: :json)

      assert_forbidden
    end

    test 'correct member permissions with correct scope' do
      member.update(allowed_sections: :policy_registry, allowed_service_ids: [service.id])
      new_token = FactoryBot.create(:access_token, owner: member.reload, scopes: %w[policy_registry]).value

      get admin_api_service_proxy_policies_path(service, access_token: new_token, format: :json)

      assert_response :success
    end

    private

    def assert_not_found
      assert_response :not_found
      expected_body = { "status" => "Not found" }
      assert_equal expected_body, JSON.parse(response.body)
    end

    def assert_forbidden
      assert_response :forbidden
      expected_body = { "error" => "Your access token does not have the correct permissions" }
      assert_equal expected_body, JSON.parse(response.body)
    end
  end
end
