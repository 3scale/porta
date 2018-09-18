require 'test_helper'

class DeveloperPortal::Admin::PlansWidgetControllerRequiringCreditCardTest < DeveloperPortal::ActionController::TestCase
  tests DeveloperPortal::Admin::PlansWidgetController

  def setup
    @provider  = FactoryGirl.create(:provider_account, :payment_gateway_type => 'braintree_blue',
                         :billing_strategy => FactoryGirl.create(:postpaid_billing, :charging_enabled => true))
    @service = @provider.default_service
    @service.update_attribute :buyer_plan_change_permission, 'request_credit_card'

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
  end

  test 'show link to enter CC details for paid plans when buyer CC details are missing and buyer is charged with wizard' do
    assert @buyer.settings.monthly_charging_enabled?
    assert @buyer.is_charged?
    refute @buyer.credit_card_stored?

    get :index, :service_id => @service.id, :application_id => @application.id, wizard: true

    url = @controller.view_context.new_admin_account_plan_change_path(contract_id: @application.id, plan_id: @paid_plan.id)

    selector = 'a[id="%s"][href="%s"]' % ["change-plan-#{@paid_plan.id}", url]
    assert_select(selector, text: 'enter your Credit Card details')
    assert_select('input[id=?]', "change-plan-#{@free_plan.id}", :value => 'Change Plan')
  end

  test 'show link to enter CC details for paid plans when buyer CC details are missing and buyer is charged without wizard' do
    assert @buyer.settings.monthly_charging_enabled?
    assert @buyer.is_charged?
    refute @buyer.credit_card_stored?

    get :index, :service_id => @service.id, :application_id => @application.id

    url =  @controller.view_context.payment_details_path

    selector = 'a[id="%s"][href="%s"]' % ["change-plan-#{@paid_plan.id}", url]
    assert_select(selector, text: 'enter your Credit Card details')
    assert_select('input[id=?]', "change-plan-#{@free_plan.id}", :value => 'Change Plan')
  end

  test 'show button to change plan when buyer is not charged' do
    @buyer.settings.update_attribute :monthly_charging_enabled, false
    refute @buyer.is_charged?
    assert_equal false, @buyer.credit_card_stored?

    get :index, :service_id => @service.id, :application_id => @application.id

    assert_select('input[id=?]', "change-plan-#{@paid_plan.id}", value: 'Change Plan')
    assert_select('input[id=?]', "change-plan-#{@free_plan.id}", value: 'Change Plan')
  end

  test 'show button to change plan when buyer CC details are stored' do
    @buyer.update_attribute :credit_card_auth_code, 'code'
    assert @buyer.is_charged?
    assert @buyer.credit_card_stored?

    get :index, :service_id => @service.id, :application_id => @application.id

    assert_select('input[id=?]', "change-plan-#{@paid_plan.id}", :value => 'Change Plan')
    assert_select('input[id=?]', "change-plan-#{@free_plan.id}", :value => 'Change Plan')
  end

end
