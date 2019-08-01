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

  test 'deleted_owner' do
    service = FactoryBot.create(:simple_service)
    metric = FactoryBot.create(:metric, service: service)
    deleted_child_but_owner_persisted = DeletedObject.create(object: metric, owner: service).id

    service = FactoryBot.create(:simple_service)
    metric = FactoryBot.create(:metric, service: service)
    deleted_child_and_owner_deleted = DeletedObject.create(object: metric, owner: service).id
    deleted_object_with_deleted_children_but_its_owner_persisted = DeletedObject.create(object: service, owner: service.account).id

    deleted_owners = DeletedObject.deleted_owner.pluck(:id)
    assert_includes deleted_owners, deleted_child_and_owner_deleted
    assert_not_includes deleted_owners, deleted_child_but_owner_persisted
    assert_not_includes deleted_owners, deleted_object_with_deleted_children_but_its_owner_persisted
  end

  test 'stale' do
    service = FactoryBot.create(:simple_service)
    metric = FactoryBot.create(:metric, service: service)
    deleted_child_but_owner_persisted_old = DeletedObject.create(object: metric, owner: service, created_at: (1.week + 1.day).ago).id

    service = FactoryBot.create(:simple_service)
    metric = FactoryBot.create(:metric, service: service)
    deleted_child_and_owner_service_deleted_old = DeletedObject.create(object: metric, owner: service, created_at: (1.week + 1.day).ago).id
    deleted_object_service_but_owner_persisted_old = DeletedObject.create(object: service, owner: service.account, created_at: (1.week + 1.day).ago).id

    service = FactoryBot.create(:simple_service)
    metric = FactoryBot.create(:metric, service: service)
    deleted_child_but_owner_persisted_recent = DeletedObject.create(object: metric, owner: service, created_at: (1.week - 1.day).ago).id

    service = FactoryBot.create(:simple_service)
    metric = FactoryBot.create(:metric, service: service)
    deleted_child_and_owner_service_deleted_recent = DeletedObject.create(object: metric, owner: service, created_at: (1.week - 1.day).ago).id
    deleted_object_service_but_owner_persisted_recent = DeletedObject.create(object: service, owner: service.account, created_at: (1.week - 1.day).ago).id

    stale = DeletedObject.stale.pluck(:id)
    assert_includes stale, deleted_child_and_owner_service_deleted_old
    assert_includes stale, deleted_object_service_but_owner_persisted_old
    assert_not_includes stale, deleted_child_but_owner_persisted_old
    assert_not_includes stale, deleted_child_and_owner_service_deleted_recent
    assert_not_includes stale, deleted_object_service_but_owner_persisted_recent
    assert_not_includes stale, deleted_child_but_owner_persisted_recent
  end
end
