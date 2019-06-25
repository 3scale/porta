# frozen_string_literal: true

require 'test_helper'

class DeletedObjectTest < ActiveSupport::TestCase
  should belong_to(:owner)
  should belong_to(:object)

  def setup
    @metric = FactoryBot.create(:metric)
    @service = metric.service
  end

  attr_reader :service, :metric

  test 'scopes metrics and contracts' do
    metrics = [metric, FactoryBot.create(:metric, service: service)]
    metrics.each { |metric| DeletedObject.create(owner: service, object: metric) }
    contracts = FactoryBot.create_list(:simple_cinstance, 2)
    contracts.each { |contract| DeletedObject.create(owner: service, object: contract) }

    assert_same_elements metrics.map(&:id),   DeletedObject.metrics.pluck(:object_id)
    assert_same_elements contracts.map(&:id), DeletedObject.contracts.pluck(:object_id)
  end

  test '.service_owner' do
    with_service_owner    = DeletedObject.create(object: metric, owner: service).id
    without_service_owner = DeletedObject.create(object: service, owner: service.account).id

    result_service_owner = DeletedObject.service_owner.pluck(:id)
    assert_includes result_service_owner, with_service_owner
    assert_not_includes result_service_owner, without_service_owner
  end

  test '.service_owner_not_exists' do
    deleted_object_service_owner_exists = DeletedObject.create(object: metric, owner: service).id

    metric = FactoryBot.create(:metric)
    deleted_object_event_service_owner_deleted = DeletedObject.create(object: metric, owner: metric.service).id
    metric.service.delete

    service = FactoryBot.create(:simple_service)
    deleted_object_non_service_owner_deleted = DeletedObject.create(object: service, owner: service.account).id
    service.account.delete

    result_service_owner_not_exists = DeletedObject.service_owner_not_exists.pluck(:id)
    assert_includes result_service_owner_not_exists, deleted_object_event_service_owner_deleted
    assert_not_includes result_service_owner_not_exists, deleted_object_service_owner_exists
    assert_not_includes result_service_owner_not_exists, deleted_object_non_service_owner_deleted
  end

  test '.service_owner_event_not_exists' do
    deleted_object_event_event_not_exists = DeletedObject.create(object: metric, owner: service).id

    metric = FactoryBot.create(:metric)
    deleted_object__event_exists = DeletedObject.create(object: metric, owner: metric.service).id
    Services::ServiceDeletedEvent.create_and_publish!(metric.service)

    service = FactoryBot.create(:simple_service)
    deleted_object_event_not_exists_and_owner_account = DeletedObject.create(object: service, owner: service.account).id

    result_service_owner_event_not_exists = DeletedObject.service_owner_event_not_exists.pluck(:id)
    assert_includes result_service_owner_event_not_exists, deleted_object_event_event_not_exists
    assert_not_includes result_service_owner_event_not_exists, deleted_object__event_exists
    assert_not_includes result_service_owner_event_not_exists, deleted_object_event_not_exists_and_owner_account
  end

  test '.stale' do
    deleted_object_service_owner_exists = DeletedObject.create(object: metric, owner: service).id

    metric = FactoryBot.create(:metric)
    deleted_object_event_service_owner_deleted_and_event_not_exists = DeletedObject.create(object: metric, owner: metric.service).id
    metric.service.delete

    metric = FactoryBot.create(:metric)
    deleted_object_service_owner_deleted_and_event_exists = DeletedObject.create(object: metric, owner: metric.service).id
    Services::ServiceDeletedEvent.create_and_publish!(metric.service)
    metric.service.delete

    service = FactoryBot.create(:simple_service)
    deleted_object_non_service_owner_deleted_and_event_not_exists = DeletedObject.create(object: service, owner: service.account).id
    service.account.delete

    result_stale = DeletedObject.stale.pluck(:id)
    assert_includes result_stale, deleted_object_event_service_owner_deleted_and_event_not_exists
    assert_not_includes result_stale, deleted_object_service_owner_exists
    assert_not_includes result_stale, deleted_object_service_owner_deleted_and_event_exists
    assert_not_includes result_stale, deleted_object_non_service_owner_deleted_and_event_not_exists
  end
end
