# frozen_string_literal: true

require 'test_helper'

class AuthorizeNetTest < ActionDispatch::IntegrationTest
  def setup
    @provider_account, plan = create_provider_account

    @provider_account.settings.allow_finance! unless @provider_account.settings.finance.allowed?
    @provider_account.settings.show_finance! unless @provider_account.settings.finance.visible?

    @buyer_account = FactoryBot.create(:buyer_account, :provider_account => @provider_account)
    @buyer_account.buy!(plan)

    login_buyer @buyer_account
  end

  test "navigate to the correct link" do
    get "/admin/account/"

    details_url = "/admin/account/authorize_net"
    assert_select('a[href=?]', details_url)
  end

  # test "new users get AddProfile link" do
  #   login_with @buyer_account.admins.first.username, 'superSecret1234#'
  #   @buyer_account.credit_card_auth_code = nil
  #   @buyer_account.credit_card_authorize_net_payment_profile_token = nil

  #   get "/admin/account/authorize_net"

  #   assert_select('form[action=?]', "https://test.authorize.net/profile//AddPayment")
  # end

  # test "old users without credit card get AddProfile link" do
  #   login_with @buyer_account.admins.first.username, 'superSecret1234#'
  #   @buyer_account.credit_card_auth_code= 'code'
  #   get "/admin/account/authorize_net"
  #   assert_select('form[action=?]', "https://test.authorize.net/profile//AddPayment")
  # end

  # test "old users with credit card get editProfile link" do
  #   login_with @buyer_account.admins.first.username, 'superSecret1234#'
  #   @buyer_account.credit_card_auth_code= 'code'
  #   get "/admin/account/authorize_net"
  #   assert_select('form[action=?]', "https://test.authorize.net/profile//editPayment")
  # end

  def create_provider_account
    provider_account = FactoryBot.create(:provider_with_billing)

    provider_account.gateway_setting.attributes = {
      gateway_type: :authorize_net,
      gateway_settings: { login: 'foo', password: 'bar' }
    } # to prevent ActiveRecord::RecordInvalid since the payment gateway has been deprecated
    provider_account.gateway_setting.save!(validate: false) # We cannot use update_columns with Oracle

    plan = FactoryBot.create(:application_plan, :issuer => provider_account.default_service)

    [provider_account, plan]
  end
end
