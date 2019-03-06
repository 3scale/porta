# frozen_string_literal: true

require 'test_helper'

class DeletedObjectEntryTest < ActiveSupport::TestCase
  should belong_to(:owner)
  should belong_to(:object)

  test 'scopes metrics and contracts' do
    service = FactoryBot.create(:simple_service)
    metrics = FactoryBot.create_list(:metric, 2)
    metrics.each { |metric| DeletedObjectEntry.create(owner: service, object: metric) }
    contracts = FactoryBot.create_list(:simple_cinstance, 2)
    contracts.each { |contract| DeletedObjectEntry.create(owner: service, object: contract) }

    assert_same_elements metrics.map(&:id),   DeletedObjectEntry.metrics.pluck(:object_id)
    assert_same_elements contracts.map(&:id), DeletedObjectEntry.contracts.pluck(:object_id)
  end
end
