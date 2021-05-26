# frozen_string_literal: true

require 'test_helper'

class AccessTokensTaskTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def test_update_apicast_master_token
    assert_enqueued_jobs 1, only: RestoreApicastMasterTokenWorker do
      execute_rake_task 'access_tokens.rake', 'access_tokens:restore_master_apicast'
    end
  end
end
