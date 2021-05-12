# frozen_string_literal: true

require 'test_helper'

class AccessTokensTaskTest < ActiveSupport::TestCase

  def test_update_apicast_master_token
    FactoryBot.create_list(:access_token, 2)
    apicast_token_name = 'APIcast master token'
    master_token = FactoryBot.create(:access_token, name: apicast_token_name, owner: master_account.first_admin!)
    random_token = SecureRandom.hex

    with_env 'APICAST_TOKEN_NAME' => apicast_token_name do
      execute_rake_task 'access_tokens.rake', 'access_tokens:update:master_apicast', random_token
    end

    master_token.reload
    assert_equal random_token, master_token.value
  end

  protected

  def with_env(env = {})
    env.transform_keys!(&:to_s)
    env.transform_values!(&:to_s)
    current_env = ENV.to_hash
    ENV.replace(current_env.merge(env))
    yield
  ensure
    ENV.replace(current_env)
  end

end
