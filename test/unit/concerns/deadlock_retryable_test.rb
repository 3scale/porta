# frozen_string_literal: true

require 'test_helper'

class DeadlockRetryableTest < ActiveSupport::TestCase
  class DummyController
    include DeadlockRetryable

    def logger
      Rails.logger
    end

    public :with_deadlock_retry
  end

  setup do
    @controller = DummyController.new
  end

  def deadlock_error
    ActiveRecord::Deadlocked.new("Mysql2::Error: Deadlock found when trying to get lock; try restarting transaction")
  end

  def test_raises_after_max_retries
    attempts = 0
    assert_raises(ActiveRecord::Deadlocked) do
      @controller.with_deadlock_retry do
        attempts += 1
        raise deadlock_error
      end
    end

    assert_equal 4, attempts # 1 initial + 3 retries
  end

  def test_does_not_rescue_other_exceptions
    assert_raises(ActiveRecord::RecordNotFound) do
      @controller.with_deadlock_retry { raise ActiveRecord::RecordNotFound }
    end
  end

end
