require 'test_helper'

class SudoTest < ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create(:simple_user)
    @user.activate!
    user_session = UserSession.create(user_id: @user.id)
    @sudo = Sudo.new(return_path: '/', user_session: user_session)
  end

  def test_correct_password?
    refute @sudo.correct_password?('invalid-password')
    assert @sudo.correct_password?('supersecret')
  end

  def test_correct_password_without_email
    @user.update_column :email, nil
    user_session = UserSession.create(user_id: @user.id)
    @sudo = Sudo.new(return_path: '/', user_session: user_session)
    assert @sudo.correct_password?('supersecret')
  end
end
