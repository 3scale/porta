# frozen_string_literal: true

require 'test_helper'

class Api::ServicesControllerTest < ActionDispatch::IntegrationTest

  setup do
    login! master_account
  end

  test 'GET index renders for Saas' do
    get admin_services_path
    assert_response :ok
    assert_template 'api/services/index'
  end

  test 'GET index is unauthorized for Master On-prem' do
    ThreeScale.stubs(master_on_premises?: true)
    get admin_services_path
    assert_response :forbidden
  end
end
