# frozen_string_literal: true

require 'test_helper'

class Master::Providers::PlansControllerTest < ActionDispatch::IntegrationTest
  def setup
    @master_member = FactoryBot.create(:member, account: master_account, state: 'active')
    @service = master_account.default_service
    @tenant = FactoryBot.create(:simple_provider, provider_account: master_account)
    @old_plan, @new_plan = FactoryBot.create_list(:application_plan, 2, service: service)
    @tenant.buy! old_plan
  end

  attr_reader :tenant, :old_plan, :new_plan, :master_member, :service

  test '#update from an unauthenticated user' do
    host! master_account.self_domain

    put master_provider_plan_path(tenant), params: { plan_id: new_plan.id, format: :js }

    assert_response :redirect
    assert_equal [old_plan.id], tenant.bought_application_plans.select(:id, :position).map(&:id)
  end

  test '#update for an admin' do
    login! master_account

    put master_provider_plan_path(tenant), params: { plan_id: new_plan.id, format: :js }

    assert_response :success
    assert_equal [new_plan.id], tenant.bought_application_plans.select(:id, :position).map(&:id)
  end

  test '#update for a member with permission partners and the service' do
    master_member.update!({member_permission_ids: ['partners'], member_permission_service_ids: [service.id]})
    login! master_account, user: master_member

    put master_provider_plan_path(tenant), params: { plan_id: new_plan.id, format: :js }

    assert_response :success
    assert_equal [new_plan.id], tenant.bought_application_plans.select(:id, :position).map(&:id)
  end

  test '#update for a member without permission partners but with the service' do
    master_member.update!({member_permission_ids: [], member_permission_service_ids: [service.id]})
    login! master_account, user: master_member

    put master_provider_plan_path(tenant), params: { plan_id: new_plan.id, format: :js }

    assert_response :forbidden
    assert_equal [old_plan.id], tenant.bought_application_plans.select(:id, :position).map(&:id)
  end

  test '#update for a member with permission partners but without the service' do
    master_member.update!({member_permission_ids: ['partners'], member_permission_service_ids: '[]'})
    login! master_account, user: master_member

    put master_provider_plan_path(tenant), params: { plan_id: new_plan.id, format: :js }

    assert_response :forbidden
    assert_equal [old_plan.id], tenant.bought_application_plans.select(:id, :position).map(&:id)
  end
end
