# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ServicesControllerTest < ActionDispatch::IntegrationTest

  setup do
    login! master_account
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
