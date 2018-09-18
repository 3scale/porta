# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

module Finance::Api
  class PaymentTransactionsTest < ActionDispatch::IntegrationTest
    setup do
      @provider = Factory(:provider_account)
      @provider.create_billing_strategy
      @provider.save!
      @key = @provider.api_key

      @buyer = Factory(:buyer_account, :provider_account => @provider)
      @invoice = Factory(:invoice, :provider_account => @provider, :buyer_account => @buyer)

      host! @provider.admin_domain
    end

    test "returns payment_transactions" do
      gr = { "transaction_id"=>"27c73cba53ec35c693c6708085fced14", "auth_response_text"=>"Exact Match",
             "avs_result"=>"Y", "error_code"=>"000", "auth_code"=>"005308"}
      Factory :payment_transaction, :invoice => @invoice, :params => gr

      get "/api/invoices/#{@invoice.id}/payment_transactions.xml?provider_key=#{@key}"

      assert_response :ok
      assert_payment_transactions @response.body
    end

    test "has payment_transactions root on the xml when the list in empty" do
      get "/api/invoices/#{@invoice.id}/payment_transactions.xml?provider_key=#{@key}"

      assert_response :ok
      assert_xml '/payment_transactions'
    end

    test "payment_transaction with nil params" do
      Factory :payment_transaction, :invoice => @invoice, :params => nil

      get "/api/invoices/#{@invoice.id}/payment_transactions.xml?provider_key=#{@key}"
      assert_response :ok
    end

    context 'security' do
      should 'deny access without provider key' do
        get "/api/invoices/#{@invoice.id}/payment_transactions.xml"
        assert_response :forbidden
      end

      should 'deny access if finance module is disabled' do
        without_finance = Factory.create(:provider_account, :billing_strategy => nil)
        buyer = Factory(:buyer_account, :provider_account => without_finance)
        invoice = Factory(:invoice, :provider_account => without_finance, :buyer_account => buyer)
        Factory.create(:payment_transaction, :success => true, :invoice => invoice)
        host! without_finance.self_domain

        get "/api/invoices/#{invoice.id}.xml?provider_key=#{without_finance.api_key}"
        assert_response :forbidden
        assert_match 'Finance module not enabled for the account', @response.body
      end

      should 'work only on provider admin domain' do
        host! @provider.domain

        get "/api/invoices/#{@invoice.id}.xml?provider_key=#{@key}"
        # TODO: make it 404 when API controller is separated from
        # frontend controller
        assert_response :forbidden
      end
    end

    should 'return 404 on non-existent invoice' do
      get '/api/invoices/WHAT_42_EVER/payment_transactions', format: 'xml', provider_key: @key
      assert_response :not_found
    end
  end # security
end
