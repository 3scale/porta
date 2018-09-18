require 'test_helper'

class DeveloperPortal::Admin::PlansWidgetControllerNotRequiringCreditCardTest < DeveloperPortal::ActionController::TestCase
  tests DeveloperPortal::Admin::PlansWidgetController

  def setup
    @provider  = FactoryGirl.create(:provider_account, :payment_gateway_type => 'braintree_blue',
                         :billing_strategy => FactoryGirl.create(:postpaid_billing, :charging_enabled => true))
    @service = @provider.default_service

    @buyer = FactoryGirl.create(:buyer_account, :provider_account => @provider)
    @buyer.buy! @service.service_plans.first

    @plan  = FactoryGirl.create :application_plan, :issuer => @service, :name => 'current plan'
    @plan.publish!

    @application = @buyer.buy! @plan
    @buyer.reload

    @paid_plan  = FactoryGirl.create :application_plan, :issuer => @service, :setup_fee => 10, :name => 'paid plan'
    @paid_plan.publish!
    @free_plan  = FactoryGirl.create :application_plan, :issuer => @service, :name => 'free plan'
    @free_plan.publish!

    host! @provider.domain
    login_as @buyer.admins.first
    assert_equal false, @service.buyer_plan_change_permission == 'request_credit_card'
  end

  test 'show allow direct plan change for paid plans' do
    get :index, :service_id => @service.id, :application_id => @application.id

    assert_select('input[id=?]', "change-plan-#{@paid_plan.id}", :value => 'Change Plan')
    assert_select('input[id=?]', "change-plan-#{@free_plan.id}", :value => 'Change Plan')
  end

end
