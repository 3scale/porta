# frozen_string_literal: true

require 'test_helper'

class SphinxIndexationWorkerTest < ActiveSupport::TestCase
  test 'it does not raises if id does not exist' do
    enable_search_jobs!
    SphinxIndexationWorker.perform_now(ThinkingSphinx::Test.indexed_models.sample, 42)
  end
end
