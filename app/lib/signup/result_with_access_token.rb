# frozen_string_literal: true

module Signup
  class ResultWithAccessToken < Signup::Result
    def local_initialize
      token_params = { name: 'Administration', scopes: %w[account_management policy_registry], 'permission': 'rw' }
      @access_token = user.access_tokens.new(token_params)
    end

    attr_accessor :access_token

    def self.name
      'SignupResultWithAccessToken'
    end
  end
end
