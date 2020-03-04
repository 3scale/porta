# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationPlansControllerTest < ActionDispatch::IntegrationTest

  def setup
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    login! current_account
    @service = FactoryBot.create(:service, account: current_account)
  end

  class ProviderAccountTest < Admin::Api::ApplicationPlansControllerTest
    def test_create_valid_params_json
      assert_difference service.application_plans.method(:count) do
        post admin_api_service_application_plans_path(application_plan_params)
        assert_response :success
        assert JSON.parse(response.body).dig('application_plan', 'id').present?
      end
      application_plan = service.application_plans.last
      assert_equal application_plan_params[:application_plan][:name], application_plan.name
      assert_equal application_plan_params[:application_plan][:system_name], application_plan.system_name
      assert_equal !application_plan_params[:application_plan][:approval_required].zero?, application_plan.approval_required
      assert_equal 'published', application_plan.state
    end

    def test_create_invalid_params_json
      assert_no_difference service.application_plans.method(:count) do
        post admin_api_service_application_plans_path(application_plan_params(state_event: 'fakestate'))
        assert_response :unprocessable_entity
        assert_equal ['invalid'], JSON.parse(response.body).dig('errors', 'state_event')
      end
    end

    def test_update_valid_params_json
      application_plan = FactoryBot.create(:application_plan, name: 'firstname', state: 'hidden', service: service)
      refute_equal 50.0, application_plan.cost_per_month.to_f
      refute_equal 20.0, application_plan.setup_fee.to_f
      refute_equal 30, application_plan.trial_period_days.to_i
      put admin_api_service_application_plan_path(application_plan, application_plan_params)
      assert_response :success
      application_plan.reload
      assert_equal 50.0, application_plan.cost_per_month.to_f
      assert_equal 20.0, application_plan.setup_fee.to_f
      assert_equal 30, application_plan.trial_period_days.to_i
      assert_equal application_plan_params[:application_plan][:name], application_plan.name
      assert_equal 'published', application_plan.state
    end

    def test_update_invalid_params_json
      original_values = {name: 'firstname', state: 'hidden', service: service}
      application_plan = FactoryBot.create(:application_plan, original_values)
      put admin_api_service_application_plan_path(application_plan, application_plan_params(state_event: 'fakestate'))
      assert_response :unprocessable_entity
      assert_equal ['invalid'], JSON.parse(response.body).dig('errors', 'state_event')
      assert_equal original_values[:name], application_plan.reload.name
      assert_equal original_values[:state], application_plan.state
    end

    def test_destroy_json
      plan = FactoryBot.create(:application_plan, service: service)
      assert_difference(service.application_plans.method(:count), -1) do
        delete admin_api_service_application_plan_path(plan.id, service_id: service.id, format: :json)
        assert_response :success
        assert_empty response.body
      end
      assert_raise ActiveRecord::RecordNotFound do
        plan.reload
      end
    end

    def test_index_json
      FactoryBot.create_list(:application_plan, 2, service: service)
      get admin_api_service_application_plans_path(service_id: service.id, format: :json)
      assert_response :success
      assert_equal 2, JSON.parse(response.body)['plans'].length
    end

    def test_approval_required
      assert_difference service.application_plans.method(:count) do
        post admin_api_service_application_plans_path(application_plan_params(approval_required: true))
        assert_response :success
        assert JSON.parse(response.body).dig('application_plan', 'id').present?
      end
      application_plan = service.application_plans.last
      assert application_plan.approval_required
    end

    private

    def current_account
      @provider ||= FactoryBot.create(:provider_account)
    end
  end

  class MasterAccountTest < Admin::Api::ApplicationPlansControllerTest
    def test_create_json_saas
      assert_difference service.application_plans.method(:count) do
        post admin_api_service_application_plans_path(application_plan_params)
        assert_response :success
        assert JSON.parse(response.body).dig('application_plan', 'id').present?
      end
    end

    def test_create_json_on_premises
      ThreeScale.stubs(master_on_premises?: true)
      assert_no_difference service.application_plans.method(:count) do
        post admin_api_service_application_plans_path(application_plan_params)
        assert_response :forbidden
        assert_equal 'Forbidden', JSON.parse(response.body)['status']
      end
    end

    def test_destroy_json_saas
      plan = FactoryBot.create(:application_plan, service: service)
      assert_difference(service.application_plans.method(:count), -1) do
        delete admin_api_service_application_plan_path(plan.id, service_id: service.id, format: :json)
        assert_response :success
        assert_empty response.body
      end
      assert_raise ActiveRecord::RecordNotFound do
        plan.reload
      end
    end

    def test_destroy_json_on_premises
      ThreeScale.stubs(master_on_premises?: true)
      plan = FactoryBot.create(:application_plan, service: service)
      assert_no_difference service.application_plans.method(:count) do
        delete admin_api_service_application_plan_path(plan.id, service_id: service.id, format: :json)
        assert_response :forbidden
        assert_equal 'Forbidden', JSON.parse(response.body)['status']
        assert plan.reload
      end
    end

    def test_index_json_saas
      FactoryBot.create_list(:application_plan, 2, service: service)
      get admin_api_service_application_plans_path(service_id: service.id, format: :json)
      assert_response :success
      assert_equal service.application_plans.count, JSON.parse(response.body)['plans'].length
    end

    def test_index_json_on_premises
      ThreeScale.stubs(master_on_premises?: true)
      get admin_api_service_application_plans_path(service_id: service.id, format: :json)
      assert_response :forbidden
      assert_equal 'Forbidden', JSON.parse(response.body)['status']
    end

    private

    def current_account
      master_account
    end
  end

  private

  attr_reader :service

  def application_plan_params(state_event: 'publish', approval_required: 0)
    @application_plan_params ||= {
      service_id: service.id,
      application_plan:
        {
          name: 'testing',
          system_name: 'testing',
          state_event: state_event,
          approval_required: approval_required,
          cost_per_month: 50,
          setup_fee: 20,
          trial_period_days: 30
        },
      format: :json
    }
  end
end
