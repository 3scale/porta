require 'test_helper'

class Logic::ProviderSettingsTest < ActiveSupport::TestCase

  test '#has_visible_services_with_plans?' do
    provider = FactoryGirl.create(:provider_account)
    provider.service_plans.update_all(state: 'hidden')

    refute provider.has_visible_services_with_plans?

    provider.settings.service_plans_ui_visible = false
    provider.settings.allow_multiple_services!
    provider.settings.show_multiple_services!
    refute provider.has_visible_services_with_plans?

    provider.default_service.service_plans.first.publish!
    provider.reload
    refute provider.has_visible_services_with_plans?

    provider.settings.service_plans_ui_visible = true
    assert provider.has_visible_services_with_plans?
  end
end
