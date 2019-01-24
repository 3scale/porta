# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ServicesControllerTest < ActionDispatch::IntegrationTest

  setup do
    login! master_account
  end

  def test_create
    Account.any_instance.stubs(can_create_service?: true)
    %i[xml json].each do |format|
      requested_name = "example name #{format.to_s}"
      requested_description = "example description #{format.to_s}"
      assert_difference(master_account.services.method(:count)) do
        post admin_api_services_path(format: format), {name: requested_name, description: requested_description}
        assert_response :created
      end
      service = master_account.services.last
      assert_equal requested_name, service.name
      assert_equal requested_description, service.description
    end
  end

  def test_update
    service = master_account.default_service
    %i[xml json].each do |format|
      requested_name = "example name #{format.to_s}"
      requested_description = "example description #{format.to_s}"
      put admin_api_service_path(service, format: format), {name: requested_name, description: requested_description}
      assert_response :ok
      assert_equal requested_name, service.reload.name
      assert_equal requested_description, service.description
    end
  end

  def test_show
    service = master_account.default_service
    %i[xml json].each do |format|
      get admin_api_service_path(service, format: format)
      assert_response :ok
      assert response.body.include?('deployment_option')
      assert response.body.include?(service.deployment_option)
    end
  end

  test 'GET index works for Saas' do
    get admin_api_services_path
    assert_response :ok
  end

  test 'GET index is unauthorized for Master On-prem' do
    ThreeScale.stubs(master_on_premises?: true)
    get admin_api_services_path
    assert_response :forbidden
  end
end
