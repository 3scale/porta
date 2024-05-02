# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::BackendApis::Stats::UsageControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    @backend_api = @provider.first_service.backend_api
  end

  attr_reader :provider, :backend_api

  test 'index' do
    login_provider @provider

    get provider_admin_backend_api_stats_usage_path(backend_api_id: @backend_api.id)

    assert_response :success
    assert_template 'stats/usage/index'
    assert_equal @backend_api.metrics, assigns(:metrics)
  end

  test 'user permissions: forbidden to member users' do
    member_user = FactoryBot.create(:member, account: provider)
    member_user.activate!
    login_provider @provider, user: member_user

    get provider_admin_backend_api_stats_usage_path(backend_api_id: @backend_api.id)
    assert_response :forbidden
  end

  test 'user permissions: allowed to member users with Analytics permissions' do
    member_user = FactoryBot.create(:member, account: provider)
    member_user.activate!
    member_user.update(allowed_sections: [:monitoring])
    login_provider @provider, user: member_user

    get provider_admin_backend_api_stats_usage_path(backend_api_id: @backend_api.id)
    assert_response :success
    assert_template 'stats/usage/index'
  end
end
