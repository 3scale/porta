# frozen_string_literal: true

require 'test_helper'

module Admin::Api::Services
  class ProxiesControllerTest < ActionDispatch::IntegrationTest
    def setup
      provider = FactoryBot.create(:provider_account)
      @service = provider.default_service
      @token = FactoryBot.create(:access_token, owner: provider.admin_user, scopes: 'account_management', permission: 'rw')
      host! provider.external_admin_domain
    end

    attr_reader :service, :token

    def test_show
      get admin_api_service_proxy_path(service_id: service.id, format: :xml, access_token: token.plaintext_value)
      assert_response :success
      xml = Hash.from_xml(response.body).fetch('proxy').except('created_at', 'updated_at')

      get admin_api_service_proxy_path(service_id: service.id, format: :json, access_token: token.plaintext_value)
      assert_response :success
      json = JSON.parse(response.body).fetch('proxy').except('created_at', 'updated_at')

      assert_equal json.transform_values(&:to_s).except('links'), xml
      assert_instance_of Array, json['policies_config']
      # this is strange but see https://issues.redhat.com/browse/THREESCALE-7605
      assert_instance_of String, xml['policies_config']
    end

    def test_update
      put admin_api_service_proxy_path(service_id: service.id, format: :xml, access_token: token.plaintext_value), params: { proxy: { credentials_location: 'headers' } }

      assert_response :success

      assert_equal 'headers', service.proxy.credentials_location
    end

    def test_updating_proxy_deploys_to_staging_without_leaving_pending_changes
      FactoryBot.create(:service_token, service: service)
      proxy = service.proxy
      proxy.update_columns(apicast_configuration_driven: true)
      ApicastV2DeploymentService.new(proxy).call(environment: :sandbox)

      assert_difference proxy.proxy_configs.sandbox.method(:count), 1 do
        with_clock_incrementing_on_each_read do
          put admin_api_service_proxy_path(service_id: service.id, format: :json, access_token: token.plaintext_value), params: {
            proxy: { credentials_location: 'headers' }
          }
        end

        assert_response :success
      end

      deployed_config = proxy.proxy_configs.sandbox.newest_first.first!
      assert_equal 'headers', JSON.parse(deployed_config.content).dig('proxy', 'credentials_location')
      assert_not_predicate proxy.reload, :pending_affecting_changes?
    end
  end
end
