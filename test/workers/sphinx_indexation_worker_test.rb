# frozen_string_literal: true

require 'test_helper'

class SphinxIndexationWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "callback" do
    account = FactoryBot.create(:simple_account)
    callback = ThinkingSphinx::RealTime.callback_for(:account)
    assert callback

    ThinkingSphinx::RealTime.expects(callback_for: callback)
    callback.expects(:after_commit).with(account)

    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs only: indexation_class do
        indexation_class.perform_later(account)
      end
    end
  end

  private
  def indexation_class
    Object.const_get(self.class.name.sub(/Test$/, ""))
  end
end
