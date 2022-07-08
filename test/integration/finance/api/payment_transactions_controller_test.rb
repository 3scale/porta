require 'test_helper'

class Finance::Api::PaymentTransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    @provider.create_billing_strategy
    @provider.save!
    @provider.settings.allow_finance!
    admin_user = @provider.admin_users.first
    @access_token = FactoryBot.create(:access_token, owner: admin_user, scopes: 'finance', permission: 'rw')

    @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
    @invoice = FactoryBot.create(:invoice, :provider_account => @provider, :buyer_account => @buyer)

    host! @provider.external_admin_domain
  end

  attr_reader :provider, :buyer, :invoice, :access_token

  test "returns payment_transactions" do
    gr = { "transaction_id"=>"27c73cba53ec35c693c6708085fced14", "auth_response_text"=>"Exact Match",
           "avs_result"=>"Y", "error_code"=>"000", "auth_code"=>"005308"}
    FactoryBot.create :payment_transaction, invoice: invoice, :params => gr

    get api_invoice_payment_transactions_path(invoice, format: :xml, access_token: access_token.value)

    assert_response :ok
    assert_payment_transactions @response.body
  end

  test "has payment_transactions root on the xml when the list in empty" do
    get api_invoice_payment_transactions_path(invoice, format: :xml, access_token: access_token.value)

    assert_response :ok
    assert_xml '/payment_transactions'
  end

  test "payment_transaction with nil params" do
    FactoryBot.create :payment_transaction, invoice: @invoice, params: nil

    get api_invoice_payment_transactions_path(invoice, format: :xml, access_token: access_token.value)
    assert_response :ok
  end

  test 'full access with provider key' do
    get api_invoice_payment_transactions_path(invoice, format: :xml, provider_key: provider.api_key)
    assert_response :ok
  end

  test 'deny access without access token or provider key' do
    get api_invoice_payment_transactions_path(invoice, format: :xml)
    get "/api/invoices/#{@invoice.id}/payment_transactions.xml"
    assert_response :forbidden
  end

  test 'deny access if finance module is disabled' do
    without_finance = FactoryBot.create(:provider_account, billing_strategy: nil)
    access_token = FactoryBot.create(:access_token, owner: without_finance.admin_users.first, scopes: 'finance', permission: 'rw')
    buyer = FactoryBot.create(:buyer_account, provider_account: without_finance)
    invoice = FactoryBot.create(:invoice, provider_account: without_finance, buyer_account: buyer)
    FactoryBot.create(:payment_transaction, success: true, invoice: invoice)
    host! without_finance.internal_admin_domain

    get api_invoice_payment_transactions_path(invoice, format: :xml, access_token: access_token.value)
    assert_response :forbidden
    assert_match 'Finance module not enabled for the account', @response.body
  end

  test 'deny access without finance scope' do
    without_finance = FactoryBot.create(:provider_account, billing_strategy: nil)
    access_token = FactoryBot.create(:access_token, owner: without_finance.admin_users.first, scopes: 'account_management', permission: 'rw')
    buyer = FactoryBot.create(:buyer_account, provider_account: without_finance)
    invoice = FactoryBot.create(:invoice, provider_account: without_finance, buyer_account: buyer)
    FactoryBot.create(:payment_transaction, success: true, invoice: invoice)
    host! without_finance.internal_admin_domain
    get api_invoice_payment_transactions_path(invoice, format: :xml, access_token: access_token.value)
    assert_response :forbidden
  end

  test 'work only on provider admin domain' do
    host! @provider.internal_domain
    get api_invoice_payment_transactions_path(invoice, format: :xml, access_token: access_token.value)
    assert_response :not_found
  end

  test 'return 404 on non-existent invoice' do
    get api_invoice_payment_transactions_path(invoice_id: 'WHAT_42_EVER', format: :xml, access_token: access_token.value)
    assert_response :not_found
  end

  test '#index for master' do
    host! master_account.internal_admin_domain
    invoice = FactoryBot.create(:invoice, provider_account: master_account)
    access_token = FactoryBot.create(:access_token, owner: master_account.first_admin, scopes: ['finance'])
    get api_invoice_payment_transactions_path(invoice, format: :xml, access_token: access_token.value)
    assert_response :success

    ThreeScale.config.stubs(onpremises: true)
    get api_invoice_payment_transactions_path(invoice, format: :xml, access_token: access_token.value)
    assert_response :forbidden
  end
end
