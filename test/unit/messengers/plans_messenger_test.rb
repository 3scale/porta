require 'test_helper'

class PlansMessengerTest < ActiveSupport::TestCase

  setup do
    Logic::RollingUpdates.expects(skipped?: true).at_least_once
  end

  test '#plan_change_request' do
    cinstance = FactoryBot.create(:cinstance)
    plan = FactoryBot.create(:account_plan)
    PlansMessenger.plan_change_request(cinstance, plan).deliver

    email = ActionMailer::Base.deliveries.last
    expected_url = Rails.application.routes.url_helpers.admin_service_application_url(cinstance.service, cinstance, host: cinstance.account.provider_account.admin_domain)
    assert_includes email.body.to_s, expected_url
  end
end
