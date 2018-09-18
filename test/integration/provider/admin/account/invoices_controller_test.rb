require 'test_helper'

class Provider::Admin::Account::InvoicesControllerTest < ActionDispatch::IntegrationTest
  test '#index for master' do
    login! master_account
    ThreeScale.config.stubs(onpremises: true)
    get provider_admin_account_invoices_path
    assert_response :forbidden

    ThreeScale.config.stubs(onpremises: false)
    get provider_admin_account_invoices_path
    assert_response :success
  end

  test '#index for provider' do
    provider = FactoryGirl.create(:provider_account)
    login! provider

    ThreeScale.config.stubs(onpremises: false)
    get provider_admin_account_invoices_path
    assert_response :success

    ThreeScale.config.stubs(onpremises: true)
    get provider_admin_account_invoices_path
    assert_response :forbidden
  end
end
