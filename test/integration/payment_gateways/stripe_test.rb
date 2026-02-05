require 'test_helper'

class StripeTest < ActionDispatch::IntegrationTest
  def setup
    @provider_account, plan = create_provider_account
    @provider_account.settings.allow_finance!
    @provider_account.settings.show_finance!

    @buyer_account = FactoryBot.create(:buyer_account, :provider_account => @provider_account)
    @buyer_account.buy!(plan)
    host! @provider_account.internal_domain
  end

  test "checks that the correct link exists" do
    login_with @buyer_account.admins.first.username, 'superSecret1234#'

    get "/admin/account/"
    details_url = "/admin/account/stripe"
    assert_select('a[href=?]', details_url)
  end

  def create_provider_account
    provider_account = FactoryBot.create(:provider_with_billing,
      payment_gateway_type: :stripe,
      payment_gateway_options: {
        number: '1234567890123456',
        cvc: '123',
        exp_month: '01',
        exp_year: '2029'
      }
                              )

    provider_account.billing_strategy = FactoryBot.create(:postpaid_with_charging)
    provider_account.payment_gateway_type = :stripe

    plan = FactoryBot.create(:application_plan, :issuer => provider_account.default_service)
    [provider_account, plan]
  end
end
