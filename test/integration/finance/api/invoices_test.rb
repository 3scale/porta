# frozen_string_literal: true

require 'test_helper'

module Finance::Api
  class InvoicesTestCommonCases < ActionDispatch::IntegrationTest
    def setup
      @provider = FactoryBot.create(:provider_account)
      @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
      @provider.create_billing_strategy
      @provider.save!
      @key = @provider.api_key

      host! @provider.admin_domain
    end

    test 'deny access without provider key' do
      get "/api/#{@context}invoices.xml"
      assert_response :forbidden
    end

    test 'deny access if finance module is disabled' do
      without_finance = FactoryBot.create(:provider_account, :billing_strategy => nil)
      host! without_finance.self_domain
      get "/api/#{@context}invoices.xml?provider_key=#{without_finance.api_key}"
      assert_response :forbidden
      assert_match 'Finance module not enabled for the account', @response.body
    end

    test 'deny access if access token does not include finance scope' do
      @provider.settings.allow_finance!
      member = FactoryBot.create(:member, account: @provider, admin_sections: [:finance])
      token  = FactoryBot.create(:access_token, owner: member)

      get "/api/invoices.xml?access_token=#{token.value}"

      assert_response :forbidden
    end

    test 'allow access if access token include finance scope' do
      @provider.settings.allow_finance!
      member = FactoryBot.create(:member, account: @provider, admin_sections: [:finance])
      token  = FactoryBot.create(:access_token, owner: member, scopes: ['finance'])

      get "/api/invoices.xml?access_token=#{token.value}"

      assert_response :success
    end

    test 'deny access if member does not have finance permission' do
      @provider.settings.allow_finance!
      member = FactoryBot.create(:member, account: @provider, admin_sections: [])
      token  = FactoryBot.create(:access_token, owner: member, scopes: ['finance'])

      get "/api/invoices.xml?access_token=#{token.value}"

      assert_response :forbidden
    end

    test 'return 404 on non-existent invoice' do
      get "/api/#{@context}invoices/42_ID.xml?provider_key=#{@key}"
      assert_response :not_found
    end

    test 'return XML invoice specified by ID' do
      setup_existing_invoices_test
      get "/api/#{@context}invoices/#{@invoice.id}.xml?provider_key=#{@key}"

      assert_response :success
      assert_select 'invoice' do
        assert_select 'invoice > id', :text => @invoice.id.to_s
        assert_select 'invoice > friendly_id', :text => @invoice.friendly_id.to_s
        assert_select 'invoice > buyer > id', @invoice.buyer_account.id.to_s
        assert_select 'line-items > line-item > cost', '10.0'
        assert_select 'invoice > cost', '20.0'
        # vat_rate and vat_amount do not show when vat_rate = 0
        assert_select 'invoice > vat_rate', :text => "0", :count => 0
        assert_select 'invoice > vat_amount', :text => "0", :count => 0
        assert_select 'invoice > cost_without_vat', '20.0'
        assert_select 'invoice > payment_transactions_count', "0"
      end
    end

    test 'work fine with deleted account' do
      setup_existing_invoices_test
      @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
      @invoice = FactoryBot.create(:invoice, :provider_account => @provider, :buyer_account => @buyer)
      @buyer.delete # destroy

      get "/api/invoices/#{@invoice.id}.xml?provider_key=#{@key}"

      assert_response :success
      assert_select 'invoice' do
        assert_select 'invoice > buyer > id', @buyer.id.to_s
        assert_select 'invoice > buyer > status', "deleted"
      end
    end

    test "have vat_rate if non negative" do
      setup_existing_invoices_test
      @buyer.vat_rate = 10.0
      @buyer.save

      get "/api/#{@context}invoices.xml?provider_key=#{@key}"

      assert_response :success
      assert_select 'invoice' do
        assert_select 'invoice > id', :text => @invoice.id.to_s
        assert_select 'invoice > cost', '22.0'
        assert_select 'invoice > vat_rate', :text => "10.0"
        assert_select 'invoice > vat_amount', '2.0'
        assert_select 'invoice > cost_without_vat', '20.0'
      end
    end

    test 'provide list of invoices' do
      setup_existing_invoices_test
      buyer = @buyer || FactoryBot.create(:buyer_account, :provider_account => @provider)

      25.times do
        FactoryBot.create(:invoice, :provider_account => @provider, :buyer_account => buyer)
      end

      get "/api/#{@context}invoices.xml?provider_key=#{@key}&page=1&per_page=21"

      assert_response :success
      assert_select 'invoices > pagination[total_pages=?]', '2'
      assert_select 'invoices > pagination[current_page=?]', '1'
      assert_select 'invoices > pagination[per_page=?]', '21'
      assert_select 'invoices > invoice', :count => 21
    end

    test 'redirect when asked for PDF' do
      setup_existing_invoices_test
      get "/api/#{@context}invoices/#{@invoice.id}.pdf?provider_key=#{@key}"
      assert_response :found
    end

    test 'filter by month' do
      setup_existing_invoices_test
      setup_filter_tests
      @invoice.update_attribute :period, Month.new(1022,5)

      get "/api/#{@context}invoices.xml?provider_key=#{@key}&month=1022-05"

      assert_response :success

      assert_select 'invoices > invoice', :count => 1
    end

    test 'filter by state' do
      setup_existing_invoices_test
      setup_filter_tests
      @invoice.cancel!

      get "/api/#{@context}invoices.xml?provider_key=#{@key}&state=cancelled"

      assert_response :success

      assert_select 'invoices > invoice', :count => 1
      assert_select 'invoices > invoice > id', :text => @invoice.id.to_s
      assert_select 'invoices > invoice > state', :text => 'cancelled'
    end

    def setup_existing_invoices_test
      @buyer ||= FactoryBot.create(:buyer_account, :provider_account => @provider)
      @invoice = FactoryBot.create(:invoice, :provider_account => @provider, :buyer_account => @buyer)
      2.times { FactoryBot.create(:line_item_plan_cost, :invoice => @invoice, :name => 'fake', :cost => 10.0) }
    end

    def setup_filter_tests
      buyer = @buyer || FactoryBot.create(:buyer_account, :provider_account => @provider)

      2.times do
        FactoryBot.create(:invoice, :provider_account => @provider, :buyer_account => buyer)
      end
    end
  end

  class InvoicesNoScopeTest < InvoicesTestCommonCases
    def setup
      super
      @context = ''
    end
  end

  class InvoicesBuyersScopeTest < InvoicesTestCommonCases
    def setup
      super
      @context = "accounts/#{@buyer.id}/"
    end
  end

  def self.runnable_methods
    return [] if self == InvoicesTestCommonCases

    super
  end
end
