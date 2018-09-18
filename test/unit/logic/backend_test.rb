require 'test_helper'

class Logic::BackendTest < ActiveSupport::TestCase

  def test_available_versions_for
    rolling_updates_off
    rolling_update(:apicast_oidc, enabled: false)
    service = FactoryGirl.create(:simple_service)
    versions = Logic::Backend::Service.available_versions_for(service)
    refute versions.values.include?('oidc')

    rolling_update(:apicast_oidc, enabled: true)
    service.proxy.update_attributes(apicast_configuration_driven: false)
    versions = Logic::Backend::Service.available_versions_for(service)
    refute versions.values.include?('oidc')

    service.proxy.update_attributes(apicast_configuration_driven: true)
    versions = Logic::Backend::Service.available_versions_for(service)
    assert versions.values.include?('oidc')
  end
end
