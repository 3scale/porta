require 'test_helper'

class PersistEventWorkerTest < ActiveSupport::TestCase

  test "enqueue" do
    assert PersistEventWorker.enqueue({a: :b})
    assert_equal 1, PersistEventWorker.jobs.size
  end

  test "enqueue send correct parameters" do
    PersistEventWorker.expects(:perform_async).with({a: :b})
    PersistEventWorker.enqueue({a: :b})
  end

  test "perform" do
    event_attrs = {id: 213, foo: :bar}

    Events::Importer.expects(:async_import_event!).with(event_attrs).once
    assert_difference "BackendEvent.count", 1 do
      PersistEventWorker.new.perform(event_attrs)
    end
    assert_equal 0, PersistEventWorker.jobs.size

    assert_difference "BackendEvent.count", 0 do
      PersistEventWorker.new.perform(event_attrs)
    end
    assert_equal 0, PersistEventWorker.jobs.size
  end

  test "perform handle ActiveRecord::RecordNotUnique" do
    BackendEvent.any_instance.expects(:save!).raises(ActiveRecord::RecordNotUnique.new("forced error", nil))
    event_attrs = {id: 213, foo: :bar}
    assert_difference "BackendEvent.count", 0 do
      PersistEventWorker.new.perform(event_attrs)
    end
    assert_equal 0, PersistEventWorker.jobs.size
  end
end
