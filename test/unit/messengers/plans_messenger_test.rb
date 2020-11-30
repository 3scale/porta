require 'test_helper'

class PlansMessengerTest < ActiveSupport::TestCase
  test '#plan_change_request' do
    rolling_updates_off
    rolling_update(:api_as_product, enabled: true)

    cinstance = FactoryBot.create(:cinstance)
    plan = FactoryBot.create(:account_plan)
    PlansMessenger.plan_change_request(cinstance, plan).deliver

    email = ActionMailer::Base.deliveries.last
    expected_url = System::UrlHelpers.system_url_helpers.admin_service_application_url(cinstance.service, cinstance, host: cinstance.account.provider_account.admin_domain)
    assert_includes email.body.to_s, expected_url
  end
end
