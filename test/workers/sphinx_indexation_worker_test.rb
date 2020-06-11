# frozen_string_literal: true

require 'test_helper'

class SphinxIndexationWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def test_indexing
    account = FactoryBot.create(:simple_account)
    callback = ThinkingSphinx::RealTime.callback_for(:account)
    assert callback

    ThinkingSphinx::RealTime.expects(callback_for: callback)
    callback.expects(:after_commit).with(account)

    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs only: SphinxIndexationWorker do
        SphinxIndexationWorker.perform_later(account)
      end
    end
  end
end
