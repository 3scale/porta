# frozen_string_literal: true

require 'test_helper'

class Api::PoliciesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.default_service
    login! @provider
    Policies::PoliciesListService.expects(:call!).returns({})
  end


  test 'update policies config without errors' do
    config = [{ 'name' => 'foo', 'version' => '1', 'configuration' => {} }].to_json
    expected_policies = [
      {"name" => "foo", "version" => "1", "configuration" => {}},
      {
        "name" => "apicast", "humanName" => "APIcast policy", "description" => "Main functionality of APIcast.",
        "configuration" => {},
        "version" => "builtin", "enabled" => true, "removable" => false, "id" => "apicast-policy"
      }
    ]
    put admin_service_policies_path(@service), params: { proxy: {policies_config: config} }
    # Checking flash won't work anymore in rails 5+
    assert_equal 'The policies are saved successfully', flash[:notice]
    assert_equal Proxy::PoliciesConfig.new(expected_policies), @service.proxy.policies_config
    assert_redirected_to edit_admin_service_policies_path(@service)
  end

  test 'invalid config - does not update policies' do
    invalid_config = 'invalid-config'.to_json
    put admin_service_policies_path(@service), params: { proxy: { policies_config: invalid_config } }
    assert_equal 'The policies cannot be saved', flash[:error]
    assert_response :unprocessable_entity
  end

  test 'update policies config with errors' do
    invalid_config = [{ 'name' => 'foo' }].to_json
    put admin_service_policies_path(@service), params: { proxy: {policies_config: invalid_config} }
    # Checking flash won't work anymore in rails 5+
    assert_equal 'The policies cannot be saved', flash[:error]
    assert_equal Proxy::PoliciesConfig.new([Proxy::PolicyConfig::DEFAULT_POLICY]), @service.proxy.policies_config
    assert_response :unprocessable_entity
  end

  test 'edit without errors in the registry' do
    get edit_admin_service_policies_path(@service)
    assert_response :success
  end

  test 'edit with errors in the registry' do
    Policies::PoliciesListService.unstub(:call!)
    Policies::PoliciesListService.expects(:call!).raises(HTTP::TimeoutError.new)
    get edit_admin_service_policies_path(@service)
    assert_response :service_unavailable
  end
end
