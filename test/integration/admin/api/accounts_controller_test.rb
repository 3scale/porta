# frozen_string_literal: true

require 'test_helper'

class Admin::API::AccountsControllerTest < ActionDispatch::IntegrationTest

  class MasterAccount < ActionDispatch::IntegrationTest

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

  disable_transactional_fixtures!

  def setup
    @provider = FactoryBot.create(:provider_account)
    host! @provider.admin_domain
    @member = FactoryBot.create(:member, account: @provider, member_permission_ids: [:partners])
    @access_token = FactoryBot.create(:access_token, owner: @member, scopes: 'account_management')
    @account = FactoryBot.create(:buyer_account, provider_account: @provider)
    @account.settings.update_column(:monthly_billing_enabled, false)
    Logic::RollingUpdates.stubs(:enabled?).returns(true)
  end

  def test_find
    account = FactoryBot.create(:simple_provider, provider: @provider)
    service = FactoryBot.create(:simple_service, account: account)
    service.service_tokens.create!(value: 'token')

    get find_admin_api_accounts_path(format: :xml, provider_key: @provider.api_key, buyer_service_token: 'token')
    assert_response :not_found

    provider_key = master_account.buyer_accounts.first.provider_key
    get find_admin_api_accounts_path(format: :xml, provider_key: @provider.api_key, buyer_provider_key: provider_key)
    assert_response :not_found

    buyer_user = @provider.buyer_users.last
    get find_admin_api_accounts_path(format: :xml, provider_key: @provider.api_key, username: buyer_user.username)
    assert_response :success

    get find_admin_api_accounts_path(format: :xml, provider_key: @provider.api_key, user_id: buyer_user.id)
    assert_response :success

    get find_admin_api_accounts_path(format: :xml, provider_key: @provider.api_key, email: buyer_user.email)
    assert_response :success
  end

  def test_show
    @access_token.permission = 'ro'
    @access_token.save!
    @account.update_columns(credit_card_auth_code: 'abcd',
      credit_card_expires_on: Date.new(2020, 4, 2), credit_card_partial_number: '0989')
    @account.payment_detail.destroy!

    assert_difference(PaymentDetail.method(:count), 0) do
      get admin_api_account_path(@account, format: :xml, access_token: @access_token.value)
      assert_response :success
    end

    @account.settings.destroy!
    assert_difference(Settings.method(:count), 0) do
      get admin_api_account_path(@account, format: :xml, access_token: @access_token.value)
      assert_response :success
    end

    assert_difference(PaymentDetail.method(:count), 1) do
      assert_difference(Settings.method(:count), 1) do
        get admin_api_account_path(@account, format: :xml, provider_key: @provider.provider_key)
        assert_response :success
      end
    end
  end

  test '#update from a member with service_permissions is updated correctly' do
    Logic::RollingUpdates::Features::ServicePermissions.any_instance.stubs(:enabled?).returns(true)

    put admin_api_account_path(@account, format: :xml), update_params
    assert_response :ok
    assert_xml '//account/id'
    assert @account.reload.settings.monthly_billing_enabled
  end

  test '#update from a member without service_permissions returns error message in xml' do
    Logic::RollingUpdates::Features::ServicePermissions.any_instance.stubs(:enabled?).returns(false)

    put admin_api_account_path(@account, format: :xml), update_params
    assert_xml_403
    refute @account.reload.settings.monthly_billing_enabled
  end

  test '#update from a member without service_permissions returns error message in json' do
    Logic::RollingUpdates::Features::ServicePermissions.any_instance.stubs(:enabled?).returns(false)

    put admin_api_account_path(@account, format: :json), update_params
    assert_equal 'Forbidden', JSON.parse(response.body).dig('status')
    assert_response :forbidden
    refute @account.reload.settings.monthly_billing_enabled
  end

  private

  def update_params
    @params ||= { monthly_billing_enabled: true, access_token: @access_token.value }
  end

end
