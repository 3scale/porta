# frozen_string_literal: true

class Signup::ResultWithAccessToken < Signup::Result
  def local_initialize
    @access_token = user.access_tokens.new({ name: 'account management rw', scopes: ['account_management'], 'permission': 'rw' })
  end

  attr_accessor :access_token

  def self.name
    'SignupResultWithAccessToken'
  end
end
