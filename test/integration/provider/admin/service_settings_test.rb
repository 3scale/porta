# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::ServiceSettingsTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)

    login_provider @provider

    host! @provider.admin_domain
  end

  def test_show
    @provider.settings.allow_service_plans!
    @provider.settings.service_plans.show!
    service = @provider.services.last

    get settings_admin_service_path(service)
    assert_response 200

    service.service_plans.destroy_all
    get settings_admin_service_path(service)
    assert_response 200

    @provider.settings.deny_service_plans!
    @provider.settings.service_plans.hide!
    get settings_admin_service_path(service)
    assert_response 200
  end
end
