# frozen_string_literal: true

require 'test_helper'

class SeedsTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  test 'the seeds do not fail' do
    assert Rails.application.load_seed
  end
end
