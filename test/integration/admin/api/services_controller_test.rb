# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ServicesControllerTest < ActionDispatch::IntegrationTest

  setup do
    login! master_account
  end

  def test_show
    get admin_api_service_path(master_account.default_service, format: :xml)
    assert_response :ok
    assert response.body.include?('deployment_option')
    assert response.body.include?(master_account.default_service.deployment_option)

    get admin_api_service_path(master_account.default_service, format: :json)
    assert_response :ok
    assert response.body.include?('deployment_option')
    assert response.body.include?(master_account.default_service.deployment_option)
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
