require 'test_helper'

class ServiceSubscriptionServiceTest < ActiveSupport::TestCase

  def setup
    @service_contract = FactoryGirl.create(:simple_service_contract)
    @buyer            = @service_contract.user_account
    @service          = @service_contract.plan.issuer
    @provider         = @service.account
    @application_plan = FactoryGirl.create(:application_plan, issuer: @service)

    @buyer.buy! @application_plan
  end

  def test_success_unsubscribe
    apps = @buyer.bought_cinstances.by_service_id(@service_contract.service_id)
    apps.update_all state: 'suspended'

    service_subscription = ServiceSubscriptionService.new(@provider)
    service_contract = service_subscription.unsubscribe(@service_contract)

    assert service_contract.destroyed?
  end

  def test_failure_unsubscribe_when_active_applications
    service_subscription = ServiceSubscriptionService.new(@buyer)
    service_contract = service_subscription.unsubscribe(@service_contract)

    refute service_contract.destroyed?
    assert_contains service_contract.errors.messages[:base], 'There is 1 unsuspended application subscribed to the service'
  end

end