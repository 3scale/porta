# frozen_string_literal: true

class Signup::ResultWithAccessToken < Signup::Result
  def local_initialize
    @access_token = user.access_tokens.new({ name: 'account management rw', scopes: ['account_management'], 'permission': 'rw' })
  end

  # This is smelly in many ways and it is pending for refactoring since the very moment we added it.
  # It would be nice to clean it as part of THREESCALE-3757 or in a new Jira issue.
  # For now I just set it in CodeClimate as "won't fix".
  attr_accessor :access_token

  def self.name
    'SignupResultWithAccessToken'
  end
end
