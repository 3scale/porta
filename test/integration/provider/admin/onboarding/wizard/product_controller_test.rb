# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Onboarding::Wizard::ProductControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    host! @provider.external_admin_domain
    login_provider @provider
  end

  test 'new' do
    get new_provider_admin_onboarding_wizard_product_path
    assert_response :success
  end

  test 'update with valid params' do
    service = @provider.first_service!

    put provider_admin_onboarding_wizard_product_path, params: { service: { name: 'New API name' } }
    assert_redirected_to new_provider_admin_onboarding_wizard_connect_path

    service.reload
    assert_equal 'New API name', service.name
  end
end
