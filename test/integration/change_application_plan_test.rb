require 'test_helper'

class ChangeApplicationPlanTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryGirl.create(:provider_account)

    login_provider @provider

    host! @provider.admin_domain
  end

  def test_change_plan
    service = FactoryGirl.create(:service, account: @provider)
    plan_1  = FactoryGirl.create(:application_plan, service: service)
    plan_2  = FactoryGirl.create(:application_plan, service: service)
    app     = FactoryGirl.create(:cinstance, service: service, plan: plan_1)

    assert_equal plan_1.id, app.plan_id
    assert_equal 1, plan_1.contracts_count
    assert_equal 0, plan_2.contracts_count

    put change_plan_admin_buyers_application_path(id: app, cinstance: { plan_id: plan_2.id })
    assert_response :redirect

    [plan_1, plan_2, app].each(&:reload)
    assert_equal plan_2.id, app.plan_id
    assert_equal 0, plan_1.contracts_count
    assert_equal 1, plan_2.contracts_count
  end
end
