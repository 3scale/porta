# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Dashboard::Service::IntegrationErrorsControllerTest < ActionController::TestCase
  setup do
    @provider = FactoryBot.create(:provider_account)
    login_provider(@provider)
  end

  test "should get show" do
    service = FactoryBot.create(:simple_service, account: @provider)
    stub_backend_service_errors(service)

    get :show, params: { service_id: service }, xhr: true
    assert_response :success
  end
end
