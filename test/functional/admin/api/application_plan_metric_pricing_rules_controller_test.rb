require 'test_helper'

class Admin::Api::ApplicationPlanMetricPricingRulesControllerTest < ActionController::TestCase

  def setup
    provider = FactoryGirl.create(:provider_account)
    service  = FactoryGirl.create(:service, account: provider)
    @plan    = FactoryGirl.create(:application_plan, service: service)
    @metric  = FactoryGirl.create(:metric, service: service)
    @rule    = FactoryGirl.create(:pricing_rule, metric: @metric, plan: @plan,
                min: 1, max: 2)

    host! provider.admin_domain

    login_provider provider
  end

  def test_index_json
    get :index, application_plan_id: @plan.id, metric_id: @metric.id, format: :json

    assert_response :success
    assert_equal 1, JSON.parse(@response.body).fetch('pricing_rules').count
  end

  def test_index_xml
    get :index, application_plan_id: @plan.id, metric_id: @metric.id, format: :xml

    assert_response :success
    assert_equal 1, xml_elements_by_key(@response.body, 'pricing_rule').count
  end

  def test_create_json
    post :create, application_plan_id: @plan.id, metric_id: @metric.id,
      pricing_rule: { min: 10, max: 20, cost_per_unit: 20.0553 }, format: :json

    assert_response :success
    assert JSON.parse(@response.body).fetch('pricing_rule').present?
  end

  def test_create_xml
    post :create, application_plan_id: @plan.id, metric_id: @metric.id,
      pricing_rule: { min: 10, max: 20, cost_per_unit: 20.0553 }, format: :xml

    assert_response :success
    assert_equal 1, xml_elements_by_key(@response.body, 'pricing_rule').count
  end

  private

  def xml_elements_by_key(xml, key)
    Nokogiri::XML::Document.parse(xml).document.children.xpath("//#{key}")
  end
end
