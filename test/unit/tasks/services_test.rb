# frozen_string_literal: true

require 'test_helper'

module Tasks
  class ServicesTest < ActiveSupport::TestCase
    test 'destroy_marked_as_deleted' do
      DestroyAllDeletedObjectsWorker.expects(:perform_async).once.with('Service')

      execute_rake_task 'services.rake', 'services:destroy_marked_as_deleted'
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
