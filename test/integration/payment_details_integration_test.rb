require 'test_helper'

class PaymentDetailsIntegrationTest < ActionDispatch::IntegrationTest
  test 'access is denied if finance is not visible' do
    provider = FactoryBot.create(:provider_account)
    plan = FactoryBot.create(:application_plan, :issuer => provider.default_service)
    buyer = FactoryBot.create(:buyer_account, :provider_account => provider)
    buyer.buy!(plan)

    host! provider.internal_domain

    assert !provider.settings.finance.visible?
    login_with buyer.admins.first.username, "superSecret1234#"

    get developer_portal.admin_account_stripe_path
    assert_response 403
  end
end
