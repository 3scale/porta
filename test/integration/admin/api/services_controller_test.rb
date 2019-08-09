# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ServicesControllerTest < ActionDispatch::IntegrationTest
  class MasterHostTest < Admin::Api::ServicesControllerTest
    setup do
      login! master_account
    end

    test 'create' do
      Account.any_instance.stubs(can_create_service?: true)
      %i[xml json].each do |format|
        requested_name = "example name #{format.to_s}"
        requested_description = "example description #{format.to_s}"
        assert_difference(master_account.services.method(:count)) do
          post admin_api_services_path(format: format), {name: requested_name, description: requested_description}
          assert_response :created
        end
        service = master_account.services.last
        assert_equal requested_name, service.name
        assert_equal requested_description, service.description
      end
    end

    test 'update' do
      service = master_account.default_service
      %i[xml json].each do |format|
        requested_name = "example name #{format.to_s}"
        requested_description = "example description #{format.to_s}"
        put admin_api_service_path(service, format: format), {name: requested_name, description: requested_description}
        assert_response :ok
        assert_equal requested_name, service.reload.name
        assert_equal requested_description, service.description
      end
    end

    test 'show' do
      service = master_account.default_service
      %i[xml json].each do |format|
        get admin_api_service_path(service, format: format)
        assert_response :ok
        assert response.body.include?('deployment_option')
        assert response.body.include?(service.deployment_option)
      end
    end

    test 'index works for SaaS but it is unauthorized for Master On-prem' do
      ThreeScale.stubs(master_on_premises?: false)
      get admin_api_services_path
      assert_response :ok

      ThreeScale.stubs(master_on_premises?: true)
      get admin_api_services_path
      assert_response :forbidden
    end
  end

  class TenantHostTest < ActionDispatch::IntegrationTest
    setup do
      @provider = FactoryBot.create(:provider_account)
      host! provider.admin_domain
    end

    attr_reader :provider

    test 'delete with api_key' do
      service = FactoryBot.create(:service, account: provider)
      assert_change(of: -> { service.reload.deleted? }, from: false, to: true) do
        delete admin_api_service_path(service, provider_key: provider.api_key)
        assert_response :ok
      end
    end
  end
end
