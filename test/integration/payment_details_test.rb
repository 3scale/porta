require 'test_helper'

class PaymentDetailsTest < ActionDispatch::IntegrationTest
  test 'access is denied if finance is not visible' do
    provider = FactoryBot.create(:provider_account)
    plan = FactoryBot.create(:application_plan, :issuer => provider.default_service)
    buyer = FactoryBot.create(:buyer_account, :provider_account => provider)
    buyer.buy!(plan)

    host! provider.domain

    assert !provider.settings.finance.visible?
    login_with buyer.admins.first.username, "supersecret"

    get developer_portal.admin_account_ogone_path
    assert_response 403
  end
end
