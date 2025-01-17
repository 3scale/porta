# frozen_string_literal: true

module Signup
  class ResultWithAccessToken < Signup::Result
    def local_initialize
      token_params = { name: 'Administration', scopes: %w[account_management policy_registry], 'permission': 'rw' }
      @access_token = user.access_tokens.new(token_params)
    end

    # This is smelly in many ways and it is pending for refactoring since the very moment we added it.
    # It would be nice to clean it as part of THREESCALE-3757 or in a new Jira issue.
    # For now I just set it in CodeClimate as "won't fix".
    attr_accessor :access_token

    def self.name
      'SignupResultWithAccessToken'
    end
  end
end
