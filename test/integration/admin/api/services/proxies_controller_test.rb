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
      get admin_api_service_proxy_path(service_id: service.id, format: :xml, access_token: token.value)
      assert_response :success
      xml = Hash.from_xml(response.body).fetch('proxy').except('created_at', 'updated_at')

      get admin_api_service_proxy_path(service_id: service.id, format: :json, access_token: token.value)
      assert_response :success
      json = JSON.parse(response.body).fetch('proxy').except('created_at', 'updated_at')

      assert_equal json.transform_values(&:to_s).except('links'), xml
      assert_instance_of Array, json['policies_config']
      # this is strange but see https://issues.redhat.com/browse/THREESCALE-7605
      assert_instance_of String, xml['policies_config']
    end

    def test_update
      put admin_api_service_proxy_path(service_id: service.id, format: :xml, access_token: token.value), params: { proxy: { credentials_location: 'headers' } }

      assert_response :success

      assert_equal 'headers', service.proxy.credentials_location
    end
  end
end
