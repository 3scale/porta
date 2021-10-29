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

  def test_show
    get admin_buyers_stats_application_path(id: @application.id)
    assert_response :success
  end

  def test_show_without_access_to_all_services
    User.any_instance.expects(:has_access_to_all_services?).returns(false).at_least_once
    get admin_buyers_stats_application_path(id: @application.id)
    assert_response :forbidden
  end

  def test_show_with_member_permissions
    get admin_buyers_stats_application_path(id: @application.id)
    assert_response :success
  end
end
