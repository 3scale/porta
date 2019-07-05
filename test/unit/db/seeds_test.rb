# frozen_string_literal: true

require 'test_helper'

class SeedsTest < ActiveSupport::TestCase
  setup do
    # some annoying test is failing to clear the db in the teardown making this one to randomly fail, so adding this to ensure the test database is "virgin"
    DatabaseCleaner.clean
  end

  disable_transactional_fixtures!

  test 'the seeds do not fail' do
    assert Rails.application.load_seed
  end
end
