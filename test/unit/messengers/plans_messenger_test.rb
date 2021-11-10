require 'test_helper'

class PlansMessengerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    Logic::RollingUpdates.expects(skipped?: true).at_least_once
  end

  test '#plan_change_request' do
    cinstance = FactoryBot.create(:cinstance)
    plan = FactoryBot.create(:account_plan)
    perform_enqueued_jobs(only: ActionMailer::DeliveryJob) do
      PlansMessenger.plan_change_request(cinstance, plan).deliver
    end

    email = ActionMailer::Base.deliveries.last
    expected_url = System::UrlHelpers.system_url_helpers.provider_admin_application_url(cinstance, host: cinstance.account.provider_account.admin_domain)
    assert_includes email.body.to_s, expected_url
  end
end
