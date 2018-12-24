require 'test_helper'


class DeveloperPortal::Admin::Account::InvoicesControllerTest < DeveloperPortal::ActionController::TestCase

  test 'access is denied if finance is not visible' do
    provider = FactoryBot.create(:provider_account)
    plan = FactoryBot.create(:application_plan, :issuer => provider.default_service)
    buyer = FactoryBot.create(:buyer_account, :provider_account => provider)
    buyer.buy!(plan)

    host! provider.domain

    assert !provider.settings.finance.visible?
    login_as buyer.admins.first

    get :index
    assert_response 403
  end

end
