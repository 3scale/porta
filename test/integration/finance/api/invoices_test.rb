# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

module Finance::Api
  class InvoicesTest < ActionDispatch::IntegrationTest

    @@common_cases = Proc.new do

      context '(security)' do

        should 'deny access without provider key' do
          get "/api/#{@context}invoices.xml"
          assert_response :forbidden
        end

        should 'deny access if finance module is disabled' do
          without_finance = Factory.create(:provider_account, :billing_strategy => nil)
          host! without_finance.self_domain
          get "/api/#{@context}invoices.xml?provider_key=#{without_finance.api_key}"
          assert_response :forbidden
          assert_match 'Finance module not enabled for the account', @response.body
        end

        should 'deny access if access token does not include finance scope' do
          member = FactoryBot.create(:member, account: @provider, admin_sections: [:finance])
          token  = FactoryBot.create(:access_token, owner: member)

          get "/api/invoices.xml?access_token=#{token.value}"

          assert_response :forbidden
        end

        should 'allow access if access token include finance scope' do
          member = FactoryBot.create(:member, account: @provider, admin_sections: [:finance])
          token  = FactoryBot.create(:access_token, owner: member, scopes: ['finance'])

          get "/api/invoices.xml?access_token=#{token.value}"

          assert_response :success
        end

        should 'deny access if member does not have finance permission' do
          member = FactoryBot.create(:member, account: @provider, admin_sections: [])
          token  = FactoryBot.create(:access_token, owner: member, scopes: ['finance'])

          get "/api/invoices.xml?access_token=#{token.value}"

          assert_response :forbidden
        end
      end

      should 'return 404 on non-existent invoice' do
        get "/api/#{@context}invoices/42_ID.xml?provider_key=#{@key}"
        assert_response :not_found
      end

      context 'with existing invoices' do
        disable_transactional_fixtures!

        setup do
          @buyer ||= Factory(:buyer_account, :provider_account => @provider)
          @invoice = Factory(:invoice, :provider_account => @provider, :buyer_account => @buyer)
          2.times { Factory(:line_item_plan_cost, :invoice => @invoice, :name => 'fake', :cost => 10.0) }
        end

        should 'return XML invoice specified by ID' do
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

        context 'with deleted account' do
          setup do
            @buyer = Factory(:buyer_account, :provider_account => @provider)

            @invoice = Factory(:invoice, :provider_account => @provider, :buyer_account => @buyer)
            # @invoice.finalize!
            # @invoice.pay!

            @buyer.delete # destroy
          end

          should 'work fine' do
            get "/api/invoices/#{@invoice.id}.xml?provider_key=#{@key}"

            assert_response :success
            assert_select 'invoice' do
              assert_select 'invoice > buyer > id', @buyer.id.to_s
              assert_select 'invoice > buyer > status', "deleted"
            end
          end
        end # with deleted account

        should "have vat_rate if non negative" do
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

        should 'provide list of invoices' do
          buyer = @buyer || Factory(:buyer_account, :provider_account => @provider)

          25.times do
            Factory(:invoice, :provider_account => @provider, :buyer_account => buyer)
          end

          get "/api/#{@context}invoices.xml?provider_key=#{@key}&page=1&per_page=21"

          assert_response :success
          assert_select 'invoices > pagination[total_pages=?]', '2'
          assert_select 'invoices > pagination[current_page=?]', '1'
          assert_select 'invoices > pagination[per_page=?]', '21'
          assert_select 'invoices > invoice', :count => 21
        end

        should 'redirect when asked for PDF' do
          get "/api/#{@context}invoices/#{@invoice.id}.pdf?provider_key=#{@key}"
          assert_response :found
        end

        context 'filter' do
          setup do
            buyer = @buyer || Factory(:buyer_account, :provider_account => @provider)

            2.times do
              Factory(:invoice, :provider_account => @provider, :buyer_account => buyer)
            end
          end

          should 'by month' do
            @invoice.update_attribute :period, Month.new(1022,5)

            get "/api/#{@context}invoices.xml?provider_key=#{@key}&month=1022-05"

            assert_response :success

            assert_select 'invoices > invoice', :count => 1
          end

          should 'filter by state' do
            @invoice.cancel!

            get "/api/#{@context}invoices.xml?provider_key=#{@key}&state=cancelled"

            assert_response :success

            assert_select 'invoices > invoice', :count => 1
            assert_select 'invoices > invoice > id', :text => @invoice.id.to_s
            assert_select 'invoices > invoice > state', :text => 'cancelled'
          end
        end
      end
    end

    context 'Invoice API[not-scoped]' do
      setup do
        @provider = Factory(:provider_account)
        @provider.create_billing_strategy
        @provider.save!
        @key = @provider.api_key

        @context = ''
        host! @provider.admin_domain
      end

      @@common_cases.call
    end

    context 'Invoice API[by buyers]' do
      setup do
        @provider = Factory(:provider_account)
        @buyer = Factory(:buyer_account, :provider_account => @provider)

        @provider.create_billing_strategy
        @provider.save!
        @key = @provider.api_key

        @context = "accounts/#{@buyer.id}/"
        host! @provider.admin_domain
      end

      @@common_cases.call
    end

  end
end
