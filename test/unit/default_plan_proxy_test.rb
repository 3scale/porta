require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class DefaultPlanProxyTest < ActiveSupport::TestCase

  def setup
    @service = Factory(:service)
    @provider = Factory(:provider_account)
  end

  test 'provider has default account plan' do
    first = Factory(:account_plan, :issuer => @provider)

    @provider.default_account_plan = first
    assert_equal first, @provider.account_plans.default
  end

  test 'service has default service plan' do
    first = Factory(:service_plan, :issuer => @service)
    assert_nil @service.service_plans.default

    @service.default_service_plan = first
    assert_equal first, @service.service_plans.default
  end

  test 'service has default application plan' do
    first = Factory(:application_plan, :issuer => @service)
    assert_nil @service.application_plans.default

    @service.default_application_plan = first
    assert_equal first, @service.application_plans.default
  end

  test 'can set default' do
    first = Factory(:application_plan, :issuer => @service)
    assert_nil @service.application_plans.default

    @service.application_plans.default = first
    assert_equal first, @service.application_plans.default
  end

end
