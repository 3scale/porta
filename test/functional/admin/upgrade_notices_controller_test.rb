require 'test_helper'

class Admin::UpgradeNoticesControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    @request.host = @provider.self_domain
    login_as(@provider.admins.first)

    # that saves us fromt the need of creating the whole 3scale plan
    # structure in the tests
    Account.any_instance.stubs(:first_plan_with_switch).returns(@provider.bought_plan)
  end

  [ :end_users, :account_plans, :service_plans, :finance,
    :multiple_services, :multiple_applications, :multiple_users,
    :groups, :branding ].map(&:to_s).each do |switch|
      test switch do
        get :show, id: switch
        assert_response :success
        assert_template 'feature_not_available'
      end
    end

end
