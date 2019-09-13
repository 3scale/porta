# frozen_string_literal: true

require 'test_helper'

class Backend::ModelExtensions::BackendApiConfigTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  test 'sync backend api metrics with backend' do
    service = FactoryBot.create(:service)
    backend_api = FactoryBot.create(:backend_api, account: service.account)
    other_metric = FactoryBot.create(:metric, owner: backend_api, system_name: 'other', service_id: nil)

    backend_api.metrics.each { |metric| metric.expects(:sync_backend_for_service).with(service) }
    service.backend_api_configs.create(backend_api: backend_api, path: 'foo')
  end
end
