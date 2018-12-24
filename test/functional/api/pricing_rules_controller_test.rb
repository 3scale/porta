require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Api::PricingRulesControllerTest < ActionController::TestCase
  def setup
    @provider_account = FactoryBot.create :provider_account
    @plan = FactoryBot.create(:application_plan, :issuer => @provider_account.default_service)
    @metric = FactoryBot.create(:metric, :service => @provider_account.default_service)

    @request.host = @provider_account.admin_domain
    login_as(@provider_account.admins.first)
  end

  test 'index with pricing rule without upper bound via ajax' do
    pricing_rule = FactoryBot.create(:pricing_rule, :plan => @plan, :min => 1, :max => nil)
    @plan.pricing_rules.stubs(:find_all_by_metric_id).with(@metric.id).returns([pricing_rule])

    xhr :get, :index, :application_plan_id => @plan.to_param, :metric_id => @metric.to_param

  end

  test 'new via ajax' do
    xhr :get, :new, :application_plan_id => @plan.to_param, :metric_id => @metric.to_param

    assert_response :success
    assert_template 'api/pricing_rules/new'
    assert assigns(:pricing_rule).is_a?(PricingRule)
  end

  test 'create via ajax' do
    old_count = @plan.pricing_rules.count
    xhr :post, :create, :application_plan_id => @plan.to_param, :metric_id => @metric.to_param

    assert_response :success
    assert_template 'api/pricing_rules/create'
    assert_equal old_count +1, @plan.pricing_rules.count
  end

  test 'edit via ajax' do
    pricing_rule = FactoryBot.create(:pricing_rule, :plan => @plan)

    xhr :get, :edit, :application_plan_id => @plan.to_param, :id => pricing_rule.to_param

    assert_response :success
    assert_template 'api/pricing_rules/edit'
    assert_equal pricing_rule, assigns(:pricing_rule)

    assert_select 'form[action=?]',
                     admin_application_plan_pricing_rule_path(@plan, pricing_rule) do
        assert_select "input[type=hidden][name=_method][value=patch]"
        assert_select 'input[type=submit]'
    end
  end

  test 'update via ajax' do
    pricing_rule = FactoryBot.create(:pricing_rule, :plan => @plan,
                           :cost_per_unit => 6)

    xhr :put, :update, :application_plan_id => @plan.to_param, :id => pricing_rule.to_param,
        :pricing_rule => {:cost_per_unit => 2}

    assert_response :success
    assert_template 'api/pricing_rules/update'
    assert_equal 2, pricing_rule.reload.cost_per_unit.to_i
  end

  test 'destroy via ajax' do
    pricing_rule = FactoryBot.create(:pricing_rule, :plan => @plan)

    xhr :delete, :destroy, :application_plan_id => @plan.to_param, :id => pricing_rule.to_param

    assert_response :success
    assert_template 'api/pricing_rules/destroy'
    assert_raise ActiveRecord::RecordNotFound do
      pricing_rule.reload
    end
  end
end
