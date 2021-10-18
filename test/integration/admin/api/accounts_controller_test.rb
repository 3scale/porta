# frozen_string_literal: true

require 'test_helper'

class Admin::Api::AccountsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    host! provider.admin_domain
  end

  attr_reader :provider

  class MasterAccountTest < ActionDispatch::IntegrationTest
    def setup
      host! master_account.admin_domain
    end

    def test_find
      account = FactoryBot.create(:simple_provider, provider: master_account)
      service = FactoryBot.create(:simple_service, account: account)
      service.service_tokens.create!(value: 'token')

      get find_admin_api_accounts_path(format: :xml, provider_key: master_account.api_key, buyer_service_token: 'token')
      assert_response :success
      get find_admin_api_accounts_path(format: :xml, provider_key: master_account.api_key, buyer_service_token: '123')
      assert_response :not_found

      provider_key = master_account.buyer_accounts.first.provider_key
      get find_admin_api_accounts_path(format: :xml, provider_key: master_account.api_key, buyer_provider_key: "#{provider_key}-123")
      assert_response :not_found
      get find_admin_api_accounts_path(format: :xml, provider_key: master_account.api_key, buyer_provider_key: provider_key)
      assert_response :success
    end
  end

  class TenantAdminTest < Admin::Api::AccountsControllerTest
    test '#find without params should not find any account even if there is one with a null email' do
      rolling_updates_on

      buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
      buyer_user = FactoryBot.create(:admin, account: buyer)
      buyer_user.update_column(:email, nil)

      get find_admin_api_accounts_path(format: :json, access_token: token.value)
      assert_response :not_found
    end
  end

  class TenantMemberTest < Admin::Api::AccountsControllerTest
    def setup
      super
      token(user: member)
    end

    test '#update from a member with service_permissions is updated correctly' do
      rolling_updates_on
      rolling_update(:service_permissions, enabled: true)

      put admin_api_account_path(buyer, format: :xml), params: update_params
      assert_response :ok
      assert_xml '//account/id'
      assert buyer.reload.settings.monthly_billing_enabled
    end

    test '#update from a member without service_permissions returns error message in xml' do
      rolling_updates_on
      rolling_update(:service_permissions, enabled: false)

      put admin_api_account_path(buyer, format: :xml), params: update_params
      assert_xml_403
      refute buyer.reload.settings.monthly_billing_enabled
    end

    test '#update from a member without service_permissions returns error message in json' do
      rolling_updates_on
      rolling_update(:service_permissions, enabled: false)

      put admin_api_account_path(buyer, format: :json), params: update_params
      assert_equal 'Forbidden', JSON.parse(response.body).dig('status')
      assert_response :forbidden
      refute buyer.reload.settings.monthly_billing_enabled
    end
  end

  class TenantProviderKeyTest < Admin::Api::AccountsControllerTest
    def test_find
      account = FactoryBot.create(:simple_provider, provider: provider)
      service = FactoryBot.create(:simple_service, account: account)
      service.service_tokens.create!(value: 'token')

      get find_admin_api_accounts_path(format: :xml, provider_key: provider.api_key, buyer_service_token: 'token')
      assert_response :not_found

      buyer_user = buyer.users.last!
      get find_admin_api_accounts_path(format: :xml, provider_key: provider.api_key, username: buyer_user.username)
      assert_response :success

      get find_admin_api_accounts_path(format: :xml, provider_key: provider.api_key, user_id: buyer_user.id)
      assert_response :success

      get find_admin_api_accounts_path(format: :xml, provider_key: provider.api_key, email: buyer_user.email)
      assert_response :success
    end
  end

  class ReadOnlyTokenTest < Admin::Api::AccountsControllerTest
    disable_transactional_fixtures!

    def test_show
      token(user: member)
      token.permission = 'ro'
      token.save!

      buyer.update_columns(credit_card_auth_code: 'abcd',
        credit_card_expires_on: Date.new(2020, 4, 2), credit_card_partial_number: '0989')
      buyer.payment_detail.destroy!

      assert_difference(PaymentDetail.method(:count), 0) do
        get admin_api_account_path(buyer, format: :xml, access_token: token.value)
        assert_response :success
      end

      buyer.settings.destroy!
      assert_difference(Settings.method(:count), 0) do
        get admin_api_account_path(buyer, format: :xml, access_token: token.value)
        assert_response :success
      end

      assert_difference(PaymentDetail.method(:count), 1) do
        assert_difference(Settings.method(:count), 1) do
          get admin_api_account_path(buyer, format: :xml, provider_key: provider.provider_key)
          assert_response :success
        end
      end
    end
  end

  class WebHooksTest < Admin::Api::AccountsControllerTest
    disable_transactional_fixtures!

    test 'update by access token fires webhooks' do
      provider.settings.allow_web_hooks!
      FactoryBot.create(:webhook, account: provider, account_updated_on: true, active: true)

      assert_difference(WebHookWorker.jobs.method(:size)) do
        put admin_api_account_path(buyer, format: :json), params: { monthly_billing_enabled: true, access_token: token.value }
        assert_response :success
      end
    end

    test 'update by provider key does not fire webhooks' do
      provider.settings.allow_web_hooks!
      FactoryBot.create(:webhook, account: provider, account_updated_on: true, active: true)

      assert_no_difference(WebHookWorker.jobs.method(:size)) do
        put admin_api_account_path(buyer, format: :json), params: { monthly_billing_enabled: true, provider_key: provider.provider_key }
        assert_response :success
      end
    end

    test 'delete by access token fires webhooks' do
      provider.settings.allow_web_hooks!
      FactoryBot.create(:webhook, account: provider, account_deleted_on: true, active: true)

      assert_difference(WebHookWorker.jobs.method(:size)) do
        delete admin_api_account_path(buyer, access_token: token.value)
        assert_response :success
      end
    end

    test 'delete by provider key does not fire webhooks' do
      provider.settings.allow_web_hooks!
      FactoryBot.create(:webhook, account: provider, account_deleted_on: true, active: true)

      assert_no_difference(WebHookWorker.jobs.method(:size)) do
        delete admin_api_account_path(buyer, provider_key: provider.provider_key)
        assert_response :success
      end
    end
  end

  private

  def buyer
    @buyer ||= FactoryBot.create(:buyer_account, provider_account: provider).tap do |buyer|
      buyer.settings.update_column(:monthly_billing_enabled, false)
    end
  end

  def update_params
    @params ||= { monthly_billing_enabled: true, access_token: token.value }
  end

  def token(user: provider.admin_user)
    @token ||= FactoryBot.create(:access_token, owner: user, scopes: 'account_management', permission: 'rw')
  end

  def member
    @member ||= FactoryBot.create(:member, account: provider, member_permission_ids: [:partners])
  end

end
