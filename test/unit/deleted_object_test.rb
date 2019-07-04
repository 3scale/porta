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

  test '.missing_owner' do
    deleted_object_ids = {}

    deleted_object_ids[:service_owner_exists] = DeletedObject.create(object: metric, owner: service).id

    other_metric = FactoryBot.create(:metric)
    deleted_object_ids[:service_owner_deleted] = DeletedObject.create(object: other_metric, owner: other_metric.service).id
    other_metric.service.delete

    other_service = FactoryBot.create(:simple_service)
    deleted_object_ids[:account_owner_exists] = DeletedObject.create(object: other_service, owner: other_service.account).id

    other_other_service = FactoryBot.create(:simple_service)
    deleted_object_ids[:account_owner_deleted] = DeletedObject.create(object: other_other_service, owner: other_other_service.account).id
    other_other_service.account.delete

    other_other_other_service = FactoryBot.create(:simple_service)
    deleted_object_ids[:object_deleted_but_account_owner_exists] = DeletedObject.create(object: other_other_other_service, owner: other_other_other_service.account).id
    other_other_other_service.delete

    expected_missing_owner_ids = deleted_object_ids.values_at(:service_owner_deleted, :account_owner_deleted).flatten
    expected_not_missing_owner_ids = deleted_object_ids.values_at(:service_owner_exists, :account_owner_exists, :object_deleted_but_account_owner_exists).flatten
    actual_missing_owner_ids = DeletedObject.missing_owner.pluck(:id)

    assert_same_elements (actual_missing_owner_ids & expected_missing_owner_ids), expected_missing_owner_ids
    assert (actual_missing_owner_ids & expected_not_missing_owner_ids).empty?
  end

  test '.missing_owner_event' do
    service_owner_missing_event = DeletedObject.create(object: metric, owner: service).id

    metric = FactoryBot.create(:metric)
    service_owner_persisted_event = DeletedObject.create(object: metric, owner: metric.service).id
    Services::ServiceDeletedEvent.create_and_publish!(metric.service)

    service = FactoryBot.create(:simple_service)
    non_service_owner_missing_event = DeletedObject.create(object: service, owner: service.account).id

    service = FactoryBot.create(:simple_service)
    non_service_owner_persisted_event = DeletedObject.create(object: service, owner: service.account).id
    Accounts::AccountDeletedEvent.create_and_publish!(service.account)

    results = DeletedObject.missing_owner_event.pluck(:id)
    assert_includes results, service_owner_missing_event
    assert_not_includes results, service_owner_persisted_event
    assert_includes results, non_service_owner_missing_event
    assert_not_includes results, non_service_owner_persisted_event
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
    assert_includes result_stale, deleted_object_non_service_owner_deleted_and_event_not_exists
  end
end
