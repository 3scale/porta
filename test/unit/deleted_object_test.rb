# frozen_string_literal: true

require 'test_helper'

class DeletedObjectTest < ActiveSupport::TestCase
  test 'scopes metrics and contracts' do
    service = FactoryBot.create(:simple_service)
    metrics = FactoryBot.create_list(:metric, 2)
    metrics.each { |metric| DeletedObject.create(owner: service, object: metric) }
    contracts = FactoryBot.create_list(:simple_cinstance, 2)
    contracts.each { |contract| DeletedObject.create(owner: service, object: contract) }

    assert_same_elements metrics.map(&:id),   DeletedObject.metrics.pluck(:object_id)
    assert_same_elements contracts.map(&:id), DeletedObject.contracts.pluck(:object_id)
  end
end
