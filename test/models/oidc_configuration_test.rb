require 'test_helper'

class OIDCConfigurationTest < ActiveSupport::TestCase

  def test_always_save_configuration_in_database
    OIDCConfiguration.create(oidc_configurable_type: 'Contract', oidc_configurable_id: 1)
    config = OIDCConfiguration.first
    json = {
      "service_accounts_enabled" => false,
      "standard_flow_enabled" => false,
      "implicit_flow_enabled" => false,
      "direct_access_grants_enabled" => false
    }
    assert_equal json, JSON.parse(config.config_before_type_cast)
  end

  def test_assign_attributes
    config = OIDCConfiguration::Config.new
    config.assign_attributes(unexisting_attribute: 'value', service_accounts_enabled: true)
    json = {
      "service_accounts_enabled" => true,
      "standard_flow_enabled" => false,
      "implicit_flow_enabled" => false,
      "direct_access_grants_enabled" => false
    }
    assert_equal json, config.attributes
  end

  def test_saving_config
    record = OIDCConfiguration.create(oidc_configurable_type: 'Contract', oidc_configurable_id: 1)
    record.implicit_flow_enabled = true
    record.standard_flow_enabled = true
    record.save!
    record.reload
    json = {
      "service_accounts_enabled" => false,
      "standard_flow_enabled" => true,
      "implicit_flow_enabled" => true,
      "direct_access_grants_enabled" => false
    }

    assert_equal json.to_json, record.config_before_type_cast
  end
end
