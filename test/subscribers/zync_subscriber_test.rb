require 'test_helper'

class ZyncSubscriberTest < ActiveSupport::TestCase

  def setup
    @subscriber = ZyncSubscriber.new
  end

  def test_create
    event = ZyncEvent.new

    assert_difference ZyncWorker.jobs.method(:size) do
      assert @subscriber.after_commit(event)
    end
  end

end
