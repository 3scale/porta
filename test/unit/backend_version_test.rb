require 'test_helper'

class BackendVersionTest < ActiveSupport::TestCase

  def test_visible_versions
    service = FactoryBot.create(:simple_service)
    versions = BackendVersion.visible_versions(service: service)
    assert versions.is_a?(Hash)
  end

  def test_visible_versions_oidc
    rolling_updates_off
    rolling_update(:apicast_oidc, enabled: false)
    service = FactoryBot.create(:simple_service)
    versions = BackendVersion.visible_versions(service: service)
    refute versions.values.include?('oidc')

    rolling_update(:apicast_oidc, enabled: true)
    service.proxy.update_attributes(apicast_configuration_driven: false)
    versions = BackendVersion.visible_versions(service: service)
    refute versions.values.include?('oidc')

    service.proxy.update_attributes(apicast_configuration_driven: true)
    versions = BackendVersion.visible_versions(service: service)
    assert versions.values.include?('oidc')
  end

  def test_visible_versions_oauth
    service = FactoryBot.create(:service, backend_version: 'oidc')
    versions = BackendVersion.visible_versions(service: service)
    assert service.oidc?
    refute versions.values.include?('oauth')

    rolling_updates_off
    rolling_update(:oauth_api, enabled: false)
    service.backend_version = 'oauth'
    assert_raise(ActiveRecord::RecordInvalid) { service.save! }

    service.backend_version = 'oauth'
    service.save!(validate: false)
    versions = BackendVersion.visible_versions(service: service)
    refute service.oidc?
    assert versions.values.include?('oauth')
  end

  def test_usable_versions
    rolling_updates_off
    service = FactoryBot.build_stubbed(:simple_service, backend_version: 'oauth')
    versions = BackendVersion.usable_versions(service: service)
    assert versions.is_a?(Array)
    assert versions.exclude?('oidc')

    rolling_update(:oauth_api, enabled: true)
    versions = BackendVersion.usable_versions(service: service)
    assert versions.include?('oauth')

    rolling_update(:oauth_api, enabled: false)
    versions = BackendVersion.usable_versions(service: service)
    refute versions.include?('oauth')

    rolling_update(:apicast_oidc, enabled: true)
    service.backend_version = 'oidc'
    versions = BackendVersion.usable_versions(service: service)
    assert versions.include?('oauth')
  end

  def test_helper_methods
    assert BackendVersion.new('1').v1?
    assert BackendVersion.new('2').v2?
    assert BackendVersion.new('oauth').oauth?
    assert_raises(NotImplementedError) { BackendVersion.new('oidc').oidc? }
  end
end
