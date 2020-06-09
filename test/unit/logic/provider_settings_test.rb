require 'test_helper'

class Logic::ProviderSettingsTest < ActiveSupport::TestCase

  test '#has_visible_services_with_plans?' do
    provider = FactoryBot.create(:provider_account)
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

  test '#multiservice?' do
    provider = FactoryBot.build(:simple_provider)
    buyer = FactoryBot.build(:simple_buyer, provider_account: provider)

    provider.stubs(multiple_accessible_services?: true)
    assert provider.multiservice?
    assert buyer.multiservice?

    provider.stubs(multiple_accessible_services?: false)
    refute provider.multiservice?
    refute buyer.multiservice?
  end

  test '#multiple_accessible_services?' do
    provider = FactoryBot.create(:simple_provider)

    FactoryBot.create_list(:simple_service, 2, account: provider)

    assert provider.multiple_accessible_services? # 2 accessible services with no scope param

    provider.services.last.mark_as_deleted!
    refute provider.multiple_accessible_services? # 1 accessible service with no scope param

    # It is scoped if the param is sent
    scoped_ids = FactoryBot.create_list(:simple_service, 2, account: provider).map(&:id)
    assert provider.multiple_accessible_services?
    refute provider.multiple_accessible_services?(Service.where(id: scoped_ids.first))
    assert provider.multiple_accessible_services?(Service.where(id: scoped_ids))
  end
end
