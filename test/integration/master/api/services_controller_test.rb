# frozen_string_literal: true

require 'test_helper'

class Master::Api::ServicesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @provider = FactoryBot.create(:provider_account, provider_account: master_account)
    @service = @provider.services.create!(system_name: 'servicename', name: 'servicename')
    host! master_account.admin_domain
  end

  attr_reader :service, :provider

  test '#destroy works for Saas' do
    delete master_api_provider_service_path(delete_params)
    assert_response :ok
    assert_raise(ActiveRecord::RecordNotFound) { service.reload }
  end

  test '#destroy is unauthorized for Master On-prem' do
    ThreeScale.stubs(master_on_premises?: true)
    delete master_api_provider_service_path(delete_params)
    assert_response :forbidden
    assert service.reload
  end

  private

  def delete_params
    { id: service.id, provider_id: provider.id, api_key: master_account.provider_key }
  end
end
