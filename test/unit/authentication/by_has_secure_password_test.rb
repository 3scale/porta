require 'test_helper'
class Authentication::ByHasSecurePasswordTest < ActiveSupport::TestCase

  def setup
    @user = FactoryBot.create(:simple_user, account: nil)
  end

  test 'new user with password_digest' do
    assert @user.authenticate('supersecret')
    assert @user.authenticated?('supersecret')
  end
end
