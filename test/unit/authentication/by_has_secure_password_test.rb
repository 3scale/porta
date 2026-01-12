require 'test_helper'
class Authentication::ByHasSecurePasswordTest < ActiveSupport::TestCase

  def setup
    @user = FactoryBot.create(:simple_user, account: nil)
  end

  test 'User creatd without old crypted_password' do
    refute @user.crypted_password
    refute @user.salt
  end

  test 'new user with password_digest' do
    assert @user.authenticate('Supersecret123+!!')
    assert @user.authenticated?('Supersecret123+!!')
  end
end
