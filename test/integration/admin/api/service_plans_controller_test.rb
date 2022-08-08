# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ServicePlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    provider.settings.allow_service_plans!

    @service = FactoryBot.create(:service, account: provider)
  end

  attr_reader :provider, :service

  class ProviderAdminTest < self
    setup do
      @token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).value
      host! @provider.external_admin_domain
    end

    test 'create' do
      assert_difference service.service_plans.method(:count) do
        post admin_api_service_service_plans_path(service_plan_params(state_event: 'publish'))
        assert_response :success
        assert JSON.parse(response.body).dig('service_plan', 'id').present?
        assert_equal service_plan_params[:service_plan][:name], JSON.parse(response.body).dig('service_plan', 'name')
        assert_equal 'published', JSON.parse(response.body).dig('service_plan', 'state')
      end
    end

    test 'create with invalid params' do
      assert_no_difference service.service_plans.method(:count) do
        post admin_api_service_service_plans_path(service_plan_params(state_event: 'fakestate'))
        assert_response :unprocessable_entity
        assert_equal ['invalid'], JSON.parse(response.body).dig('errors', 'state_event')
      end
    end

    test 'update' do
      service_plan = FactoryBot.create(:service_plan, name: 'firstname', state: 'hidden', service: service)
      put admin_api_service_service_plan_path(service_plan, service_plan_params )
      assert_response :success
      assert_equal service_plan_params[:service_plan][:name], service_plan.reload.name
      assert_equal 'published', service_plan.state
    end

    test 'update with invalid params' do
      original_values = {name: 'firstname', state: 'hidden', service: service}
      service_plan = FactoryBot.create(:service_plan, original_values)
      put admin_api_service_service_plan_path(service_plan, service_plan_params(state_event: 'fakestate') )
      assert_response :unprocessable_entity
      assert_equal ['invalid'], JSON.parse(response.body).dig('errors', 'state_event')
      assert_equal original_values[:name], service_plan.reload.name
      assert_equal original_values[:state], service_plan.state
    end

    test 'approval required' do
      assert_difference service.service_plans.method(:count) do
        post admin_api_service_service_plans_path(service_plan_params(approval_required: true))
        assert_response :success
        assert JSON.parse(response.body).dig('service_plan', 'id').present?
      end
      service_plan = service.service_plans.last
      assert service_plan.approval_required
    end

    private

    def service_plan_params(state_event: 'publish', approval_required: 0)
      @service_plan_params ||= { service_id: service.id, service_plan: { name: 'testing', system_name: 'system_name', state_event: state_event, approval_required: approval_required }, format: :json, access_token: @token }
    end
  end

  class ProviderMemberTest < self
    setup do
      @service_plan = FactoryBot.create(:service_plan, name: 'Plan allowed', state: 'published', service: service)

      @forbidden_service = FactoryBot.create(:simple_service, account: provider)
      @forbidden_service_plan = FactoryBot.create(:service_plan, name: 'Forbidden Plan', state: 'published', service: forbidden_service)

      @member = FactoryBot.create(:member, account: provider, member_permission_ids: ['partners'])
      member.member_permission_service_ids = [service.id]
      member.activate!

      login!(provider, user: member)
    end

    attr_reader :member, :service_plan, :forbidden_service, :forbidden_service_plan

    test 'index' do
      get admin_service_service_plans_path(service_id: service.id)
      assert_response :forbidden

      member.member_permission_ids = ['plans']
      member.save!

      get admin_service_service_plans_path(service_id: service.id)
      assert_response :success

      get admin_service_service_plans_path(service_id: forbidden_service.id)
      assert_response :not_found
    end

    test 'masterize' do
      other_service_plan = FactoryBot.create(:service_plan, name: 'Other allowed plan', state: 'published', service: service)
      other_forbidden_service_plan = FactoryBot.create(:service_plan, name: 'Other forbidden plan', state: 'published', service: forbidden_service)

      post masterize_admin_service_service_plans_path(service_id: service.id), xhr: true, params: { id: other_service_plan.id }
      assert_response :forbidden

      member.member_permission_ids = ['plans']
      member.save!

      post masterize_admin_service_service_plans_path(service_id: service.id), xhr: true, params: { id: other_service_plan.id }
      assert_response :redirect
      assert_equal other_service_plan, service.reload.default_service_plan

      post masterize_admin_service_service_plans_path(service_id: service.id), xhr: true
      assert_response :redirect
      assert_equal nil, service.reload.default_service_plan

      post masterize_admin_service_service_plans_path(service_id: forbidden_service.id), xhr: true, params: { id: other_forbidden_service_plan.id }
      assert_response :not_found
    end

    test 'new' do
      get new_admin_service_service_plan_path(service_id: service.id)
      assert_response :forbidden

      member.member_permission_ids = ['plans']
      member.save!

      get new_admin_service_service_plan_path(service_id: service.id)
      assert_response :success

      get new_admin_service_service_plan_path(service_id: forbidden_service.id)
      assert_response :not_found
    end

    test 'create' do
      post admin_service_service_plans_path(service_id: service.id), params: service_plan_params
      assert_response :forbidden

      member.member_permission_ids = ['plans']
      member.save!

      post admin_service_service_plans_path(service_id: service.id), params: service_plan_params
      assert_response :redirect

      post admin_service_service_plans_path(service_id: forbidden_service.id), params: service_plan_params
      assert_response :not_found
    end

    test 'edit' do
      get edit_admin_service_plan_path(service_plan)
      assert_response :forbidden

      member.member_permission_ids = ['plans']
      member.save!

      get edit_admin_service_plan_path(service_plan)
      assert_response :success

      get edit_admin_service_plan_path(forbidden_service_plan)
      assert_response :not_found
    end

    test 'update' do
      put admin_service_plan_path(service_plan), params: service_plan_params
      assert_response :forbidden

      member.member_permission_ids = ['plans']
      member.save!

      put admin_service_plan_path(service_plan), params: service_plan_params
      assert_response :redirect

      put admin_service_plan_path(forbidden_service_plan), params: service_plan_params
      assert_response :not_found
    end

    test 'destroy' do
      delete admin_service_plan_path(service_plan)
      assert_response :forbidden

      member.member_permission_ids = ['plans']
      member.save!

      delete admin_service_plan_path(service_plan)
      assert_response :success
      assert_equal 'The plan was deleted', (JSON.parse response.body)['notice']

      delete admin_service_plan_path(forbidden_service_plan)
      assert_response :not_found
    end

    protected

    def service_plan_params
      { service_plan: { name: 'New Service Plan', approval_required: false } }
    end
  end
end
