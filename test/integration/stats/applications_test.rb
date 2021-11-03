# frozen_string_literal: true

require 'test_helper'

class Stats::ApplicationsTest < ActionDispatch::IntegrationTest

  def setup
    @provider    = FactoryBot.create(:provider_account)
    @service     = @provider.default_service
    @plan        = FactoryBot.create(:simple_application_plan, issuer: @service)
    @application = FactoryBot.create(:simple_cinstance, plan: @plan)

    host! @provider.admin_domain
    login_provider @provider
  end

  should '#show nonexistent application does not check permissions' do
    User.any_instance.expects(:has_access_to_all_services?).never
    User.any_instance.expects(:member_permission_service_ids).never

    get admin_buyers_stats_application_path(id: 'foo')
    assert_response :not_found
  end

  context 'with access to all services' do
    setup do
      User.any_instance.expects(:has_access_to_all_services?).returns(true).at_least_once
    end

    should '#show does not check member permission' do
      User.any_instance.expects(:member_permission_service_ids).never
      get admin_buyers_stats_application_path(id: @application.id)
      assert_response :success
    end
  end

  context 'without access to all services' do
    setup do
      User.any_instance.expects(:has_access_to_all_services?).returns(false).at_least_once
    end

    should '#show needs member permission' do
      User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
      get admin_buyers_stats_application_path(id: @application.id)
      assert_response :success
    end

    should '#show is forbidden without member permission' do
      User.any_instance.expects(:member_permission_service_ids).returns([]).at_least_once
      get admin_buyers_stats_application_path(id: @application.id)
      assert_response :forbidden
    end
  end
end
