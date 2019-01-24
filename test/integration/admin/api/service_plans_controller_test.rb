# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ServicePlansControllerTest < ActionDispatch::IntegrationTest

  def setup
    provider = FactoryBot.create(:provider_account)
    login! provider
    @service = FactoryBot.create(:service, account: provider)
  end

  def test_create_valid_params_json
    assert_difference service.service_plans.method(:count) do
      post admin_api_service_service_plans_path(service_plan_params(state_event: 'publish'))
      assert_response :success
      assert JSON.parse(response.body).dig('service_plan', 'id').present?
      assert_equal service_plan_params[:service_plan][:name], JSON.parse(response.body).dig('service_plan', 'name')
      assert_equal 'published', JSON.parse(response.body).dig('service_plan', 'state')
    end
  end

  def test_create_invalid_params_json
    assert_no_difference service.service_plans.method(:count) do
      post admin_api_service_service_plans_path(service_plan_params(state_event: 'fakestate'))
      assert_response :unprocessable_entity
      assert_equal ['invalid'], JSON.parse(response.body).dig('errors', 'state_event')
    end
  end

  def test_update_valid_params_json
    service_plan = FactoryBot.create(:service_plan, name: 'firstname', state: 'hidden', service: service)
    put admin_api_service_service_plan_path(service_plan, service_plan_params)
    assert_response :success
    assert_equal service_plan_params[:service_plan][:name], service_plan.reload.name
    assert_equal 'published', service_plan.state
  end

  def test_update_invalid_params_json
    original_values = {name: 'firstname', state: 'hidden', service: service}
    service_plan = FactoryBot.create(:service_plan, original_values)
    put admin_api_service_service_plan_path(service_plan, service_plan_params(state_event: 'fakestate'))
    assert_response :unprocessable_entity
    assert_equal ['invalid'], JSON.parse(response.body).dig('errors', 'state_event')
    assert_equal original_values[:name], service_plan.reload.name
    assert_equal original_values[:state], service_plan.state
  end

  def test_approval_required
    assert_difference service.service_plans.method(:count) do
      post admin_api_service_service_plans_path(service_plan_params(approval_required: true))
      assert_response :success
      assert JSON.parse(response.body).dig('service_plan', 'id').present?
    end
    service_plan = service.service_plans.last
    assert service_plan.approval_required
  end

  private

  attr_reader :service

  def service_plan_params(state_event: 'publish', approval_required: 0)
    @service_plan_params ||= { service_id: service.id, service_plan: { name: 'testing', state_event: state_event, approval_required: approval_required }, format: :json }
  end
end
