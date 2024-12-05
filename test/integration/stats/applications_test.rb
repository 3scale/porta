# frozen_string_literal: true

require 'test_helper'

class Stats::ApplicationsTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.default_service
    @plan = FactoryBot.create(:simple_application_plan, issuer: @service)
    @application = FactoryBot.create(:simple_cinstance, plan: @plan)
    @member = FactoryBot.create(:member, account: @provider, member_permission_ids: %i[partners plans], state: 'active')

    host! @provider.external_admin_domain
    login_provider @provider, user: @member
  end

  test '#show nonexistent application does not check permissions' do
    User.any_instance.expects(:member_permission_service_ids).never

    get admin_buyers_stats_application_path(id: 'foo')
    assert_response :not_found
  end

  test '#show succeeds with access to all services' do
    assert_nil @member.member_permission_service_ids
    get admin_buyers_stats_application_path(id: @application.id)
    assert_response :success
  end

  test '#show succeeds with permission for a specific service' do
    @member.update(member_permission_service_ids: [@service.id])
    get admin_buyers_stats_application_path(id: @application.id)
    assert_response :success
  end

  test '#show is forbidden without member permission' do
    @member.update(member_permission_service_ids: [])
    get admin_buyers_stats_application_path(id: @application.id)
    assert_response :forbidden
  end
end
