# frozen_string_literal: true

require 'test_helper'

class DeletedObjectTest < ActiveSupport::TestCase
  test 'scopes metrics, contracts and users' do
    service = FactoryBot.create(:simple_service)
    account = service.account
    metrics = FactoryBot.create_list(:metric, 2)
    metrics.each { |metric| DeletedObject.create(owner: service, object: metric) }
    contracts = FactoryBot.create_list(:simple_cinstance, 2)
    contracts.each { |contract| DeletedObject.create(owner: service, object: contract) }
    users = FactoryBot.create_list(:member, 2, account: account)
    users.each { |user| DeletedObject.create(owner: account, object: user) }

    assert_same_elements metrics.map(&:id),   DeletedObject.metrics.pluck(:object_id)
    assert_same_elements contracts.map(&:id), DeletedObject.contracts.pluck(:object_id)
    assert_same_elements users.map(&:id),     DeletedObject.users.pluck(:object_id)
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
    deleted_child_but_owner_persisted_old = deleted_child_and_owner_service_deleted_old = deleted_object_service_but_owner_persisted_old = nil
    Timecop.freeze((1.week + 1.day).ago) do
      service = FactoryBot.create(:simple_service)
      metric = FactoryBot.create(:metric, service: service)
      deleted_child_but_owner_persisted_old = DeletedObject.create(object: metric, owner: service).id

      service = FactoryBot.create(:simple_service)
      account = service.account
      metric = FactoryBot.create(:metric, service: service)
      deleted_child_and_owner_service_deleted_old = DeletedObject.create(object: metric, owner: service).id
      deleted_object_service_but_owner_persisted_old = DeletedObject.create(object: service, owner: account).id
    end

    deleted_child_but_owner_persisted_recent = deleted_child_and_owner_service_deleted_recent = deleted_child_and_owner_account_deleted_recent = nil
    deleted_object_service_but_owner_persisted_recent = deleted_object_account_but_owner_persisted_recent = nil
    Timecop.freeze((1.week - 1.day).ago) do
      service = FactoryBot.create(:simple_service)
      metric = FactoryBot.create(:metric, service: service)
      deleted_child_but_owner_persisted_recent = DeletedObject.create(object: metric, owner: service).id

      service = FactoryBot.create(:simple_service)
      account = service.account
      metric = FactoryBot.create(:metric, service: service)
      deleted_child_and_owner_service_deleted_recent = DeletedObject.create(object: metric, owner: service).id
      deleted_child_and_owner_account_deleted_recent = DeletedObject.create(object: account.admin_user, owner: account).id
      deleted_object_service_but_owner_persisted_recent = DeletedObject.create(object: service, owner: account).id
      deleted_object_account_but_owner_persisted_recent = DeletedObject.create(object: account, owner: master_account).id
    end


    stale = DeletedObject.stale.pluck(:id)
    assert_includes stale, deleted_child_and_owner_service_deleted_old
    assert_includes stale, deleted_object_service_but_owner_persisted_old
    assert_not_includes stale, deleted_child_but_owner_persisted_old
    assert_not_includes stale, deleted_child_but_owner_persisted_recent
    assert_not_includes stale, deleted_child_and_owner_service_deleted_recent
    assert_not_includes stale, deleted_child_and_owner_account_deleted_recent
    assert_not_includes stale, deleted_object_service_but_owner_persisted_recent
    assert_not_includes stale, deleted_object_account_but_owner_persisted_recent
  end
end
