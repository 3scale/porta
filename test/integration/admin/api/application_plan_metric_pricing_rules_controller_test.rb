# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationPlanMetricPricingRulesControllerTest < ActionDispatch::IntegrationTest
  def setup
    provider = FactoryBot.create(:provider_account)
    service  = FactoryBot.create(:service, account: provider)
    @plan    = FactoryBot.create(:application_plan, service: service)
    @metric  = FactoryBot.create(:metric, owner: service)
    @access_token_value = FactoryBot.create(:access_token, owner: provider.admin_user, scopes: %w[account_management]).value

    host! provider.admin_domain
  end

  attr_reader :plan, :metric, :access_token_value

  def test_index_json
    index_test(format: :json) do
      assert_equal 1, JSON.parse(response.body).fetch('pricing_rules').count
    end
  end

  def test_index_xml
    index_test(format: :xml) do
      assert_equal 1, xml_elements_by_key(response.body, 'pricing_rule').count
    end
  end

  def test_returns_success_if_backend_is_used_by_the_product
    backend = FactoryBot.create(:backend_api)
    metric.update!(owner: backend)
    FactoryBot.create(:backend_api_config, backend_api: backend, service: plan.service)

    index_test(format: :json) do
      assert_equal 1, JSON.parse(response.body).fetch('pricing_rules').count
    end
  end

  def test_returns_not_found_if_backend_is_not_used_by_the_product
    backend = FactoryBot.create(:backend_api)
    metric.update!(owner: backend)

    get admin_api_application_plan_metric_pricing_rules_path(application_plan_id: plan.id, metric_id: metric.id,
      format: :json, access_token: access_token_value)

    assert_response :not_found
  end

  def test_create_json
    create_test format: :json do
      assert JSON.parse(response.body).fetch('pricing_rule').present?
    end
  end

  def test_create_xml
    create_test format: :xml do
      assert_equal 1, xml_elements_by_key(response.body, 'pricing_rule').count
    end
  end

  def test_delete
    rule = FactoryBot.create(:pricing_rule, metric: metric, plan: plan, min: 1, max: 2)

    delete admin_api_application_plan_metric_pricing_rule_path(
      application_plan_id: plan.id, metric_id: metric.id, id: rule.id,
      format: :json, access_token: access_token_value
    )

    assert_response :success
    assert_raise(ActiveRecord::RecordNotFound){ rule.reload }
  end

  private

  def index_test(format:)
    FactoryBot.create(:pricing_rule, metric: metric, plan: plan, min: 1, max: 2)

    get admin_api_application_plan_metric_pricing_rules_path(application_plan_id: plan.id, metric_id: metric.id,
      format: format, access_token: access_token_value)

    assert_response :success
    yield if block_given?
  end

  def create_test(format:)
    post admin_api_application_plan_metric_pricing_rules_path(application_plan_id: plan.id, metric_id: metric.id,
      pricing_rule: { min: 10, max: 20, cost_per_unit: 20.0553 }, format: format, access_token: access_token_value)

    assert_response :success
    yield if block_given?
  end

  def xml_elements_by_key(xml, key)
    Nokogiri::XML::Document.parse(xml).document.children.xpath("//#{key}")
  end
end
