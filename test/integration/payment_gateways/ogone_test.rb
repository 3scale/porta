# frozen_string_literal: true

require 'test_helper'

class OgoneTest < ActionDispatch::IntegrationTest
  def setup
    @provider_account, plan = create_provider_account
    @provider_account.save
    @provider_account.settings.allow_finance!
    @provider_account.settings.show_finance!

    @buyer_account = FactoryBot.create(:buyer_account, :provider_account => @provider_account)
    @buyer_account.buy!(plan)

    login_buyer @buyer_account
  end

  test "navigate to the correct link" do
    get "/admin/account/"

    # active_merchant sets type to bogus and don't know how to change it
    details_url = "/admin/account/ogone"
    assert_select('a[href=?]', details_url)
  end


  test "receive ok for storage changes customer data" do
    assert_nil @buyer_account.credit_card_partial_number
    get "/admin/account/ogone/hosted_success", params: { "CN"=>"Josep Maria Pujol Serra", "orderID"=>"raitest_1323947064", "PAYID"=>"413811165", "amount"=>"0.01", "action"=>"hosted_success", "ALIAS"=>"3scale-959306862-959421232", "ACCEPTANCE"=>"211730", "CARDNO"=>"XXXXXXXXXXXX2053", "IP"=>"81.38.77.15", "PM"=>"CreditCard", "TRXDATE"=>"12/15/11", "currency"=>"EUR", "controller"=>"accounts/payment_gateways/ogone", "SHASIGN"=>"B49A41EB7302FCDEAB6BDB17DE8B9045DC020096", "BRAND"=>"VISA", "ED"=>"0215", "STATUS"=>"5", "NCERROR"=>"0" }

    @buyer_account.reload
    assert_equal  Date.new(2015, 02, 1), @buyer_account.credit_card_expires_on_with_default
    assert_equal "2053", @buyer_account.credit_card_partial_number
    assert_equal  "3scale-#{@provider_account.id}-#{@buyer_account.id}", @buyer_account.credit_card_auth_code
  end

  test "supports empty ED" do
    assert_nil @buyer_account.credit_card_partial_number
    get "/admin/account/ogone/hosted_success", params: { "ACCEPTANCE" => "0000", "BRAND" => "PAYPAL", "CARDNO" => "Batman@t-XXXXXXXX-et", "CN"=> "Bruce Wayne", "ED"=>"", "IP"=> "213.133.142.4", "NCERROR" => "0", "PAYID"=>"413811165", "PM" => "PAYPAL", "SHASIGN" => "077FAFE22C99336ACCFD032CA0687B76299A0112", "STATUS" => "5", "TRXDATE" => "10/29/14", "action" => "hosted_success", "amount" => "0.01", "controller" => "developer_portal/admin/account/ogone", "currency" => "GBP", "orderID"=>"raitest_1323947064" }

    @buyer_account.reload
    assert_equal "X-et", @buyer_account.credit_card_partial_number
    assert_equal  "3scale-#{@provider_account.id}-#{@buyer_account.id}", @buyer_account.credit_card_auth_code
    assert_equal PaymentGateways::OgoneCrypt::DEFAULT_EXPIRATION_DATE, @buyer_account.credit_card_expires_on_with_default
  end

  test "nok status value (!=5) doesn't change customer data" do
    assert_nil @buyer_account.credit_card_partial_number
    get "/admin/account/ogone/hosted_success", params: { "CN"=>"Josep Maria Pujol Serra", "orderID"=>"raitest_1323947064", "PAYID"=>"413811165", "amount"=>"0.01", "action"=>"hosted_success", "ALIAS"=>"3scale-959306862-959421232", "ACCEPTANCE"=>"211730", "CARDNO"=>"XXXXXXXXXXXX2053", "IP"=>"81.38.77.15", "PM"=>"CreditCard", "TRXDATE"=>"12/15/11", "currency"=>"EUR", "controller"=>"accounts/payment_gateways/ogone", "SHASIGN"=>"BC313E2D30365DCF887CD77CF760F8FE952BF661", "BRAND"=>"VISA", "ED"=>"0215", "STATUS"=>"1", "NCERROR"=>"0" }

    @buyer_account.reload
    assert_nil @buyer_account.credit_card_partial_number
    assert_nil @buyer_account.credit_card_auth_code
  end

  test "bad sha1 hash doesn't change customer data" do
    assert_nil @buyer_account.credit_card_partial_number
    get "/admin/account/ogone/hosted_success", params: { "CN"=>"Josep Maria Pujol Serra", "orderID"=>"raitest_1323947064", "PAYID"=>"413811165", "amount"=>"0.01", "action"=>"hosted_success", "ALIAS"=>"3scale-959306862-959421232", "ACCEPTANCE"=>"211730", "CARDNO"=>"XXXXXXXXXXXX2053", "IP"=>"81.38.77.15", "PM"=>"CreditCard", "TRXDATE"=>"12/15/11", "currency"=>"EUR", "controller"=>"accounts/payment_gateways/ogone", "SHASIGN"=>"B49A41EB7302FCDEAB6BDB17DE8B9045DC020095", "BRAND"=>"VISA", "ED"=>"0215", "STATUS"=>"5", "NCERROR"=>"0" }

    @buyer_account.reload
    assert_nil @buyer_account.credit_card_partial_number
    assert_nil @buyer_account.credit_card_auth_code
  end

  def create_provider_account
    provider_account = FactoryBot.create(:provider_with_billing)

    provider_account.gateway_setting.attributes = {
      gateway_type: :ogone,
      gateway_settings: { signature_out: "foo", login: 'foo', user: 'user', password: 'bar'}
    } # to prevent ActiveRecord::RecordInvalid since the payment gateway has been deprecated
    provider_account.gateway_setting.save!(validate: false) # We cannot use update_columns wit Oracle

    plan = FactoryBot.create(:application_plan, :issuer => provider_account.default_service)

    [provider_account, plan]
  end
end
