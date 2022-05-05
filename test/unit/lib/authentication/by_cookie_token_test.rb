# frozen_string_literal: true

require 'test_helper'

module Authentication
  class ByCookieTokenTest < ActiveSupport::TestCase
    test '#forget_me' do
      user = FactoryBot.create(:user, remember_token_expires_at: Time.current, remember_token: 123)

      user.forget_me
      assert_nil user.remember_token_expires_at
      assert_nil user.remember_token

      user.reload
      assert_nil user.remember_token_expires_at
      assert_nil user.remember_token
    end
  end
end
