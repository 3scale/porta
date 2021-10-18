# frozen_string_literal: true

require 'test_helper'
require 'sidekiq/testing'

class ServiceNotDeletedTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  disable_transactional_fixtures!

  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.net', from_email: 'support@example.net')
    login! @provider
  end

  def test_not_deleted
    @provider.settings.allow_multiple_services!

    perform_enqueued_jobs(except: [IndexProxyRuleWorker, SphinxIndexationWorker]) do
      (ENV['BRUTOFORCE'].present? ? 2000 : 1).times do |i|
        service_name = "service foo #{i}"
        post(admin_api_services_path, params: { provider_key: @provider.api_key, format: :json, name: service_name })
        assert_response :success
        assert_service(@response.body, { account_id: @provider.id, name: service_name })
        new_service = @provider.services.find_by_name(service_name)
        assert new_service

        delete admin_api_service_path(new_service.id, provider_key: @provider.api_key, format: :json)
        assert_response 200
        assert_raise(ActiveRecord::RecordNotFound) { Service.find(new_service.id) }
      end
    end
  end
end
