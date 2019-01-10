require 'test_helper'

class Service::EndUserPlanTest < ActiveSupport::TestCase

  context "service without end user registration required" do
    subject do
      service = FactoryBot.create(:service)
      plan    = FactoryBot.create(:end_user_plan, :service => service)

      service.account.settings.allow_end_users!

      service.default_end_user_plan = plan
      service.end_user_registration_required = false
      service.save!
      service
    end

    should validate_presence_of(:default_end_user_plan)
  end

  context "service with end user registation required" do
    subject { FactoryBot.create(:service, :end_user_registration_required => true) }
    should_not validate_presence_of(:default_end_user_plan)
  end

end
