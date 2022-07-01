# frozen_string_literal: true

require 'test_helper'

class Admin::Api::AccountsTest < ActionDispatch::IntegrationTest
  include FieldsDefinitionsHelpers
  include TestHelpers::ApiPagination

  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')

    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @buyer.buy! @provider.default_account_plan

    @application_plan = FactoryBot.create(:application_plan, issuer: @provider.default_service)
    @application_plan.publish!

    @buyer.buy! @application_plan

    host! @provider.internal_admin_domain
  end

  class AccessTokenTest < Admin::Api::AccountsTest
    test '#index without token' do
      get admin_api_accounts_path(format: :xml)
      assert_response :forbidden
    end

    class AdminUserTest < AccessTokenTest
      def setup
        super
        admin = FactoryBot.create(:admin, account: @provider, admin_sections: [])
        @token = FactoryBot.create(:access_token, owner: admin, scopes: 'account_management')
      end

      test 'admin can update' do
        put admin_api_account_path(@buyer, format: :xml), params: params.merge({ org_name: 'alaska' })
        assert_response :success
      end

      test '#destroy' do
        delete admin_api_account_path(format: :xml, id: @buyer.id), params: params
        assert_response :success
      end

      test 'change plan' do
        plan = FactoryBot.create(:account_plan, issuer: @provider)
        put change_plan_admin_api_account_path(@buyer, format: :xml), params: params.merge({ plan_id: plan.id })
        assert_response :success
      end

      test '#approve' do
        Account.any_instance.expects(:approve).returns(true)
        put approve_admin_api_account_path(@buyer, format: :xml), params: params
        assert_response :success
      end

      test '#reject' do
        Account.any_instance.expects(:reject).returns(true)
        put reject_admin_api_account_path(@buyer, format: :xml), params: params
        assert_response :success
      end

      test 'update billing_address' do
        put admin_api_account_path(@buyer, format: :xml), params: params.merge({ org_name: 'alaska', billing_address: 'Calle Napoles 187, Barcelona. Spain' })
        assert_response :unprocessable_entity

        billing_address = { name: '3scale', address1: 'Calle Napoles 187', city: 'Barcelona', country:  'Spain' }.transform_keys { |k| "billing_address[#{k}]" }
        put admin_api_account_path(@buyer, format: :xml), params: params.merge(billing_address).merge({ org_name: 'alaska' })
        assert_response :success
      end

      test '#update' do
        rolling_updates_off
        put admin_api_account_path(@buyer, format: :xml), params: params.merge({ org_name: 'alaska' })
        assert_response :success
      end

      test '#change_plan' do
        rolling_updates_off
        plan = FactoryBot.create(:account_plan, issuer: @provider)
        put change_plan_admin_api_account_path(@buyer, format: :xml), params: params.merge({ plan_id: plan.id })
        assert_response :success
      end
    end

    class MemberUserTest < AccessTokenTest
      class WithoutAdminSectionsTest < MemberUserTest
        def setup
          super
          member = FactoryBot.create(:member, account: @provider, admin_sections: [])
          @token = FactoryBot.create(:access_token, owner: member, scopes: 'account_management')
        end

        test '#index' do
          get admin_api_accounts_path(format: :xml), params: params
          assert_response :forbidden
        end

        test '#show' do
          get admin_api_account_path(@buyer, format: :xml), params: params
          assert_response :forbidden
        end

        test '#find without id' do
          get find_admin_api_accounts_path(format: :xml), params: params
          assert_response :forbidden
        end

        test '#find' do
          get find_admin_api_accounts_path(format: :xml), params: params.merge({ username: @buyer.users.first.username })
          assert_response :forbidden
        end

        test 'changing billing status' do
          put admin_api_account_path(@buyer, format: :xml), params: params.merge({ monthly_billing_enabled: true,
                                                                                   monthly_charging_enabled: true,
                                                                                   org_name: 'ooooooooo' })
          assert_response :forbidden
        end

        test '#destroy' do
          delete admin_api_account_path(format: :xml, id: @buyer.id), params: params
          assert_response :forbidden
        end

        test '#reject' do
          put reject_admin_api_account_path(@buyer, format: :xml), params: params
          assert_response :forbidden
        end

        test '#approve' do
          put approve_admin_api_account_path(@buyer, format: :xml), params: params
          assert_response :forbidden
        end

        test '#update' do
          rolling_updates_on
          put admin_api_account_path(@buyer, format: :xml), params: params.merge({ org_name: 'alaska' })
          assert_response :forbidden
        end

        test '#change_plan' do
          plan = FactoryBot.create(:account_plan, issuer: @provider)
          put change_plan_admin_api_account_path(@buyer, format: :xml), params: params.merge({ plan_id: plan.id })
          assert_response :forbidden
        end
      end

      class WithAdminSectionsTest < MemberUserTest
        def setup
          super
          member = FactoryBot.create(:member, account: @provider, admin_sections: %w[partners])
          @token = FactoryBot.create(:access_token, owner: member, scopes: 'account_management')
        end

        attr_reader :token

        test '#index' do
          get admin_api_accounts_path(format: :xml), params: params
          assert_response :success
        end

        test '#show' do
          get admin_api_account_path(@buyer, format: :xml), params: params
          assert_response :success
        end

        test '#find without id' do
          get find_admin_api_accounts_path(format: :xml), params: params
          assert_response :not_found
        end

        test '#find' do
          get find_admin_api_accounts_path(format: :xml), params: params.merge({ username: @buyer.users.first.username })
          assert_response :success
        end

        test 'changing billing status' do
          settings = @buyer.settings
          settings.update!(monthly_charging_enabled: false, monthly_billing_enabled: false)
          assert_not settings.monthly_charging_enabled
          assert_not settings.monthly_billing_enabled

          put admin_api_account_path(@buyer, format: :xml), params: {
            access_token: token.value,
            monthly_billing_enabled: true,
            monthly_charging_enabled: true,
            org_name: 'ooooooooo'
          }
          assert_response :success

          settings.reload
          assert settings.monthly_charging_enabled
          assert settings.monthly_billing_enabled
        end

        test '#destroy' do
          delete admin_api_account_path(format: :xml, id: @buyer.id), params: params
          assert_response :forbidden
        end

        test '#reject' do
          put reject_admin_api_account_path(@buyer, format: :xml), params: params
          assert_response :forbidden
        end

        test '#approve' do
          put approve_admin_api_account_path(@buyer, format: :xml), params: params
          assert_response :forbidden
        end

        test '#update when service_permissions rolling update is disabled' do
          rolling_updates_off
          put admin_api_account_path(@buyer, format: :xml), params: params.merge({ org_name: 'alaska' })
          assert_response :forbidden
        end

        test '#change_plan when service_permissions rolling update is disabled' do
          rolling_updates_off
          plan = FactoryBot.create(:account_plan, issuer: @provider)
          put change_plan_admin_api_account_path(@buyer, format: :xml), params: params.merge({ plan_id: plan.id })
          assert_response :forbidden
        end

        test '#update when service_permissions rolling update is enabled' do
          rolling_updates_off
          rolling_update(:service_permissions, enabled: true)
          put admin_api_account_path(@buyer, format: :xml), params: params.merge({ org_name: 'alaska' })
          assert_response :success
        end

        test '#change_plan when service_permissions rolling update is enabled' do
          rolling_updates_off
          rolling_update(:service_permissions, enabled: true)
          plan = FactoryBot.create(:account_plan, issuer: @provider)
          put change_plan_admin_api_account_path(@buyer, format: :xml), params: params.merge({ plan_id: plan.id })
          assert_response :success
        end
      end
    end

    protected

    def access_token_params(token = @token)
      { access_token: token.value }
    end

    alias params access_token_params
  end

  class ProviderKeyTest < Admin::Api::AccountsTest
    test 'index' do
      get admin_api_accounts_path(format: :xml), params: params

      assert_response :success
      assert_accounts @response.body
    end

    test 'pagination is off unless needed' do
      buyers_max = @provider.buyers.count

      get admin_api_accounts_path(format: :xml), params: params.merge({ per_page: (buyers_max +1) })

      assert_response :success
      assert_not_pagination @response.body, "accounts"
    end

    test 'index is paginated' do
      buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      buyer.buy! @provider.default_account_plan

      buyers_max = @provider.buyers.count

      get admin_api_accounts_path(format: :xml), params: params.merge({ per_page: (buyers_max -1) })

      assert_response :success
      assert_pagination @response.body, "accounts"
    end

    test 'pagination per_page has a maximum allowed' do
      max_per_page = set_api_pagination_max_per_page(to: 1)

      buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      buyer.buy! @provider.default_account_plan

      get admin_api_accounts_path(format: :xml), params: params.merge({ per_page: (max_per_page +1) })

      assert_response :success
      assert_pagination(@response.body, "accounts", per_page: max_per_page)
    end

    test 'pagination page defaults to 1 for invalid values' do
      buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      buyer.buy! @provider.default_account_plan

      set_api_pagination_max_per_page(to: 1)

      get admin_api_accounts_path, params: params.merge({ page: "invalid" })

      assert_response :success
      assert_pagination @response.body, "accounts", current_page: "1"
    end

    test 'pagination per_page defaults to max for invalid values' do
      buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      buyer.buy! @provider.default_account_plan

      max_per_page = set_api_pagination_max_per_page(to: 1)

      get admin_api_accounts_path, params: params.merge({ per_page: "invalid" })

      assert_response :success
      assert_pagination @response.body, "accounts", per_page: max_per_page
    end

    test 'pagination per_page defaults to 1 for values lesser than 1' do
      buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      buyer.buy! @provider.default_account_plan
      buyer2 = FactoryBot.create(:buyer_account, provider_account: @provider)
      buyer2.buy! @provider.default_account_plan

      set_api_pagination_max_per_page(to: 2)

      get admin_api_accounts_path, params: params.merge({ per_page: "-1" })

      assert_response :success
      assert_pagination @response.body, "accounts", per_page: "2"
    end

    test 'index returns extra fields escaped' do
      field_defined(@provider, { target: "Account", name: "some_extra_field" })

      @buyer.reload
      @buyer.extra_fields = { some_extra_field: "< > &" }
      @buyer.save

      get admin_api_accounts_path(format: :xml), params: params

      assert_response :success
      assert_accounts(@response.body, extra_fields: { some_extra_field: '&lt; &gt; &amp;' })
    end

    test 'security wise: index is access denied in buyer side' do
      host! @provider.internal_domain
      get admin_api_accounts_path(format: :xml), params: params

      assert_response :forbidden
    end

    test 'index approved' do
      #building a pending one to assert it does no go in the search afterward
      buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      buyer.buy! @provider.default_account_plan

      buyer.make_pending!
      assert_equal 'pending', buyer.state

      get admin_api_accounts_path(format: :xml), params: params.merge({ state: 'approved' })

      assert_response :success
      assert_accounts @response.body, state: 'approved'
    end

    test 'index by states is paginated' do
      2.times do
        buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
        buyer.buy! @provider.default_account_plan
        buyer.make_pending!
        assert_equal buyer.state, 'pending'
      end

      get admin_api_accounts_path(format: :xml), params: params.merge({ state: 'pending', per_page: 1, page: 1 })

      assert_response :success
      assert_pagination @response.body, "accounts"
    end

    test 'index pending' do
      buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      buyer.buy! @provider.default_account_plan
      buyer.make_pending!
      assert_equal buyer.state, 'pending'

      get admin_api_accounts_path(format: :xml), params: params.merge({ state: 'pending' })

      assert_response :success
      assert_accounts @response.body, state: 'pending'
    end

    test 'index rejected' do
      buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      buyer.buy! @provider.default_account_plan
      buyer.reject!
      assert_equal buyer.state, 'rejected'

      get admin_api_accounts_path(format: :xml), params: params.merge({ state: 'rejected' })

      assert_response :success
      assert_accounts @response.body, state: 'rejected'
    end

    test 'find accounts by username or user_id or email empty when empty' do
      assert_equal 1, @provider.buyer_users.size

      buyer1 = FactoryBot.create(:buyer_account, provider_account: @provider)
      buyer2 = FactoryBot.create(:buyer_account, provider_account: @provider)

      assert_not_nil buyer1.emails.first
      assert_not_nil buyer1.users.first.username
      assert_not_nil buyer1.users.first.id

      assert_not_nil buyer2.emails.first
      assert_not_nil buyer2.users.first.username
      assert_not_nil buyer2.users.first.id

      assert_equal 3, @provider.buyer_users.size

      get find_admin_api_accounts_path(format: :xml), params: params.merge({ username: "#{buyer1.users.first.username}_fake" })
      assert_xml_404

      get find_admin_api_accounts_path(format: :xml), params: params.merge({ user_id: - 1 })
      assert_xml_404

      get find_admin_api_accounts_path(format: :xml), params: params.merge({ email: "#{buyer2.emails.first}_fake" })
      assert_xml_404

      get find_admin_api_accounts_path(format: :xml), params: params
      assert_xml_404
    end

    test 'account find' do
      assert_equal 1, @provider.buyer_users.size

      buyer1 = FactoryBot.create(:buyer_account, provider_account: @provider)
      buyer1.buy! @provider.default_account_plan
      buyer1.reload

      buyer2 = FactoryBot.create(:buyer_account, provider_account: @provider)
      buyer2.buy! @provider.default_account_plan
      buyer2.reload

      assert_not_nil buyer1.emails.first
      assert_not_nil buyer1.users.first.username
      assert_not_nil buyer1.users.first.id

      assert_not_nil buyer2.emails.first
      assert_not_nil buyer2.users.first.username
      assert_not_nil buyer2.users.first.id

      assert_equal 3, @provider.buyer_users.size

      get find_admin_api_accounts_path(format: :xml), params: params.merge({ username: buyer1.users.first.username })

      assert_response :success
      assert_equal @response.body, buyer1.to_xml

      get find_admin_api_accounts_path(format: :xml), params: params.merge({ user_id: buyer1.users.first.id })

      assert_response :success
      assert_equal @response.body, buyer1.to_xml

      get find_admin_api_accounts_path(format: :xml), params: params.merge({ username: "#{buyer1.users.first.username}_fake", email: buyer2.emails.first })

      assert_xml_404

      get find_admin_api_accounts_path(format: :xml), params: params.merge({ email: buyer2.emails.first })

      assert_response :success
      assert_equal @response.body, buyer2.to_xml
    end

    test 'show' do
      get admin_api_account_path(@buyer, format: :xml), params: params

      assert_response :success
      assert_account(@response.body, { created_at: @buyer.created_at.xmlschema, updated_at: @buyer.updated_at.xmlschema })
    end

    test 'show returns fields defined' do
      FactoryBot.create(:fields_definition, account: @provider, target: "Account", name: "org_legaladdress")
      FactoryBot.create(:fields_definition, account: @provider, target: "Account", name: "country")

      country = Country.first

      @buyer.update org_legaladdress: "non < > &", country_id: country.id

      get admin_api_account_path(@buyer, format: :xml), params: params

      assert_response :success
      assert_account(@response.body, { org_legaladdress: "non &lt; &gt; &amp;", country: country.name })
    end

    test 'show does not returns fields not defined' do
      @buyer.update org_legaladdress: "legal-address-not-returned"

      assert @buyer.defined_fields.map(&:name).exclude?(:org_legaladdress)

      get admin_api_account_path(@buyer, format: :xml), params: params

      assert_response :success
      xml = Nokogiri::XML::Document.parse(@response.body)
      assert xml.xpath('.//account/org_legaladdress').empty?
    end

    test 'update' do
      put admin_api_account_path(@buyer, format: :xml), params: params.merge({ org_name: "updated" })

      assert_response :success
      assert_account(@response.body, { id: @buyer.id, org_name: "updated" })

      @buyer.reload
      assert_equal @buyer.org_name, "updated"
    end

    test 'update with extra fields' do
      field_defined(@provider, { target: "Account", name: "some_extra_field" })

      put admin_api_account_path(@buyer, format: :xml), params: params.merge({ some_extra_field: "stuff", vat_rate: 33 })

      assert_response :success
      assert_account(@response.body, { id: @buyer.id, extra_fields: { some_extra_field: "stuff" }})

      @buyer.reload
      assert_equal "stuff", @buyer.extra_fields["some_extra_field"]
      assert_equal 33, @buyer.vat_rate
    end

    test 'destroy' do
      delete admin_api_account_path(format: :xml, id: @buyer.id), params: params

      assert_response :success
      assert_empty_xml response.body
    end

    test 'destroy not found' do
      delete admin_api_account_path(format: :xml, id: 0), params: params

      assert_xml_404
    end

    test 'make_pending' do
      assert_not @buyer.pending?

      put make_pending_admin_api_account_path(@buyer, format: :xml), params: params

      assert_response :success
      assert_account(@response.body, { id: @buyer.id, state: "pending" })

      @buyer.reload
      assert @buyer.pending?
    end

    test 'approve' do
      @buyer.make_pending!
      assert @buyer.pending?

      put approve_admin_api_account_path(@buyer, format: :xml), params: params

      assert_response :success
      assert_account(@response.body, { id: @buyer.id, state: "approved" })

      @buyer.reload
      assert @buyer.approved?
    end

    test 'reject' do
      assert_not @buyer.rejected?

      put reject_admin_api_account_path(@buyer, format: :xml), params: params

      assert_response :success
      assert_account(@response.body, { id: @buyer.id, state: "rejected" })

      @buyer.reload
      assert @buyer.rejected?
    end

    test 'stats aggregation in master' do
      stub_request(:post, 'http://example.org/transactions.xml')
        .to_return(status: 202, body: '')
      Account.master.services.first.metrics.create! friendly_name: "Account Management API", system_name: "account", unit: "hit"

      Admin::Api::AccountsController.any_instance.expects(:report_traffic)

      get admin_api_accounts_path(format: :xml), params: params
      assert_response :success
      assert_accounts @response.body
    end

    private

    def provider_key_params
      { provider_key: @provider.api_key }
    end

    alias params provider_key_params
  end
end
