# frozen_string_literal: true

require 'test_helper'

module DataMigrations
  class UpdateMetricOwnersTest < DataMigrationTest
    test 'updates metrics owned by services' do
      metrics = FactoryBot.create_list(:metric, 3)
      Metric.where(id: metrics.map(&:id)).update_all(owner_id: nil, owner_type: nil)
      FactoryBot.create(:metric, service_id: nil, owner: FactoryBot.create(:backend_api))
      assert_change of: ->{ Metric.where(owner_type: 'Service').count }, by: 3 do
        UpdateMetricOwners.new.up
      end
    end
  end
end
