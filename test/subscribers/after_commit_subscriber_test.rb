require 'test_helper'

class AfterCommitSubscriberTest < ActiveSupport::TestCase

  class DummieEvent < RailsEventStore::Event

    def self.create(dummie)
      new(name: dummie.name)
    end

    def after_commit
      true
    end

    def after_rollback
      true
    end
  end

  def setup
    @dummie_object = OpenStruct.new(name: 'Supetramp')
  end

  def test_create
    subscriber = AfterCommitSubscriber.new
    event      = DummieEvent.create(@dummie_object)

    assert subscriber.call(event)
  end

  def test_after_commit_callback
    subscriber = AfterCommitSubscriber.new
    event      = DummieEvent.create(@dummie_object)
    callback   = AfterCommitSubscriber::AfterCommitCallback.new(event, subscriber)

    event.expects(:after_commit).once
    subscriber.expects(:after_commit).returns(true).once

    assert callback.committed!

    event.expects(:after_rollback).once
    subscriber.expects(:after_rollback).returns(true).once

    assert callback.rolledback!
  end

  class WithoutTransactionsTest < ActiveSupport::TestCase
    disable_transactional_fixtures!

    def setup
      @dummie_object = OpenStruct.new(name: 'Supetramp')
    end

    def test_call
      event        = DummieEvent.create(@dummie_object)
      subscriber_1 = AfterCommitSubscriber.new
      subscriber_2 = AfterCommitSubscriber.new

      ActiveRecord::Base.transaction do
        subscriber_1.call(event)
        subscriber_2.call(event)

        subscriber_1.expects(:after_commit).once
        subscriber_2.expects(:after_commit).once
      end
    end
  end
end
