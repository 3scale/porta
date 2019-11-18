# frozen_string_literal: true

require 'test_helper'

module Tasks
  class ServicesTest < ActiveSupport::TestCase
    test 'destroy_marked_as_deleted' do
      DestroyAllDeletedObjectsWorker.expects(:perform_async).once.with('Service')

      execute_rake_task 'services.rake', 'services:destroy_marked_as_deleted'
    end

    test 'create_backend_apis' do
      provider = FactoryBot.create(:simple_provider)
      services = FactoryBot.create_list(:simple_service, 7, account: provider)
      services.each { |service| service.proxy.update_column(:api_backend, 'https://api.example.com') }

      # 1st service already has backend api
      services.first.backend_api_configs.create(backend_api: FactoryBot.create(:backend_api, account: provider), path: '/')

      # 2nd and 3rd services don't have backend_api but neither their proxy have a private_endpoint
      services[1..2].each { |service| service.proxy.update_column(:api_backend, nil) }

      assert_change of: ->{ provider.backend_apis.count }, by: 4 do
        execute_rake_task 'services.rake', 'services:create_backend_apis'
      end
    end

    test 'update_metric_owners' do
      metrics = FactoryBot.create_list(:metric, 3)
      Metric.where(id: metrics.map(&:id)).update_all(owner_id: nil, owner_type: nil)
      FactoryBot.create(:metric, service_id: nil, owner: FactoryBot.create(:backend_api))
      assert_change of: ->{ Metric.where(owner_type: 'Service').count }, by: 3 do
        execute_rake_task 'services.rake', 'services:update_metric_owners'
      end
    end
  end
end
