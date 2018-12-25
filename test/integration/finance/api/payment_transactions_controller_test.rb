require 'test_helper'

class Finance::Api::PaymentTransactionsControllerTest < ActionDispatch::IntegrationTest

  test '#index' do
    provider = FactoryBot.create(:provider_with_billing)
    login_provider provider

    invoice = FactoryBot.create(:invoice, provider_account: provider)

    get api_invoice_payment_transactions_path(invoice), nil, accept: Mime[:json]
    assert_response :success
  end

  test '#index for master' do
    login_provider master_account

    invoice = FactoryBot.create(:invoice, provider_account: master_account)

    get api_invoice_payment_transactions_path(invoice), nil, accept: Mime[:json]
    assert_response :success

    ThreeScale.config.stubs(onpremises: true)
    get api_invoice_payment_transactions_path(invoice), nil, accept: Mime[:json]
    assert_response :forbidden
  end
end
