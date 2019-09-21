require 'test_helper'

class GatewayConfigurationTest < ActiveSupport::TestCase

  test 'a nil column always creates a valid settings' do
    config = GatewayConfiguration.new
    config.save!
    config.update_column :settings, nil
    config.reload
    assert config.valid?
    assert_equal Hash.new, config.settings
  end

  test 'saves changes to the configuration' do
    proxy = FactoryBot.create(:proxy, jwt_claim_with_client_id_type: 'plain', jwt_claim_with_client_id: 'azp')
    config = proxy.gateway_configuration
    assert config.persisted?
    config.reload
    proxy.reload
    assert_equal 'plain', proxy.jwt_claim_with_client_id_type
    assert_equal 'azp', config.jwt_claim_with_client_id
    assert_equal 'plain', config.jwt_claim_with_client_id_type
    assert_equal 'azp', config.jwt_claim_with_client_id
  end

  test 'JWT Claims with CliendID all or none specified' do
    config = GatewayConfiguration.new
    assert config.valid?
    config.jwt_claim_with_client_id_type = 'plain'
    assert config.invalid?
    config.jwt_claim_with_client_id = 'azp'
    assert config.valid?
    config.jwt_claim_with_client_id_type = nil
    assert config.invalid?
  end
end
