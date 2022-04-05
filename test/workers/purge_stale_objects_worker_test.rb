# frozen_string_literal: true

require 'test_helper'

class PurgeStaleObjectsWorkerTest < ActiveSupport::TestCase
  test 'perform for events' do
    events = FactoryBot.create_list(:event, 2)
    EventStore::Event.expects(:stale).returns(EventStore::Event.where(id: events.map(&:id)))

    events.each { |event| DeleteObjectHierarchyWorker.expects(:perform_later).with(event) }

    PurgeStaleObjectsWorker.new.perform(EventStore::Event.name)
  end

  test 'perform for DeletedObject' do
    metrics = FactoryBot.create_list(:metric, 2)
    deleted_objects = metrics.map { |metric| DeletedObject.create!(object: metric, owner: metric.owner) }
    DeletedObject.expects(:stale).returns(DeletedObject.where(id: deleted_objects.map(&:id)))

    deleted_objects.each { |deleted_obj| DeleteObjectHierarchyWorker.expects(:perform_later).with(deleted_obj) }

    PurgeStaleObjectsWorker.new.perform(DeletedObject.name)
  end
end
