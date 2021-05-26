# frozen_string_literal: true

require 'test_helper'

class RestoreApicastMasterTokenWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include WithEnv

  def test_update_apicast_master_token
    FactoryBot.create_list(:access_token, 2)
    apicast_token_name = 'APIcast master token'
    master_token = FactoryBot.create(:access_token, name: apicast_token_name, owner: master_account.first_admin!)
    random_token = SecureRandom.hex

    with_env 'APICAST_ACCESS_TOKEN' => random_token, 'APICAST_TOKEN_NAME' => apicast_token_name do
      RestoreApicastMasterTokenWorker.new.perform
    end

    master_token.reload
    assert_equal random_token, master_token.value
  end
end
