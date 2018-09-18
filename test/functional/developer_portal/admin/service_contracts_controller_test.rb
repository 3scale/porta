require 'test_helper'


class DeveloperPortal::Admin::ServiceContractsControllerTest <  DeveloperPortal::ActionController::TestCase

  def setup
    @buyer = Factory(:buyer_account)
    @provider = @buyer.provider_account
    @provider.settings.allow_multiple_services!
    @provider.settings.show_multiple_services!
    @request.host = @provider.domain
    login_as(@buyer.admins.first)
  end

  # TODO: test "new accepts :plan_id parameter"


  test "new accepts optional :service_id parameter" do
    carnivore_plan = Factory(:service_plan,
                             :name => 'Carnivore',
                             :issuer => @provider.services.first)
    carnivore_plan.publish!

    second = Factory(:service, :account => @provider)
    Factory(:service_plan,  :name => 'Dummy to not go by fast lane', :issuer => second).publish!
    herbivore_plan = Factory(:service_plan,  :name => 'Herbivore', :issuer => second)
    herbivore_plan.publish!

    get :new, :service_id => second.id

    assert_response :success
    assert_not_match /Carnivore/, @response.body
    assert_match /Herbivore/, @response.body
  end

end
