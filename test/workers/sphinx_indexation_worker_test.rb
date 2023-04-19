# frozen_string_literal: true

require 'test_helper'

class SphinxIndexationWorkerTest < ActiveSupport::TestCase

  include ActiveJob::TestHelper

  test "callback" do
    account = FactoryBot.create(:simple_account)
    callback = ThinkingSphinx::RealTime.callback_for(:account)
    assert callback

    ThinkingSphinx::RealTime.expects(callback_for: callback)
    callback.expects(:after_commit).with(Equals.new(account))
    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs only: SphinxIndexationWorker do
        SphinxIndexationWorker.perform_later(account.class, account.id)
      end
    end
  end

  test "only one index found per indexed model" do
    worker = SphinxIndexationWorker.new
    indices = ThinkingSphinx::Test.indexed_models.select do |model|
      assert_equal 1, worker.send(:indices_for_model, model).to_a.size
    end

    assert_not_empty indices.map(&:name)
  end

  test 'it does not raises if id does not exist' do
    SphinxIndexationWorker.perform_now(ThinkingSphinx::Test.indexed_models.sample, 42)
  end
end
