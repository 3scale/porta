require 'test_helper'

class SignupServiceTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryGirl.create(:provider_account)
    @session  = ActionDispatch::Request.new({}).session
  end

  def test_new
    assert new_instance_signup_service
  end

  def test_create
    service = new_instance_signup_service
    assert_difference(User.method(:count), 0) do
      user = service.create
      refute user.persisted?
    end

    service = new_instance_signup_service(valid_account_params, valid_user_params)
    assert_difference(User.method(:count), +1) do
      user = service.create
      assert user.persisted?
    end

    service = new_instance_signup_service(valid_account_params, valid_user_params)
    assert_difference(User.method(:count), +1) do
      signup = service.create { |_signup| [] }
      assert signup.persisted?
    end

    service = new_instance_signup_service(valid_account_params, valid_user_params)
    assert_difference(User.method(:count), 0) do
      service.create { |signup| @signup = signup; break }
      refute @signup.persisted?
    end
  end

  private

  def new_instance_signup_service(account_params = {}, user_params = {})
    SignupService.new(
      provider:       @provider,
      plans:          [],
      session:        @session,
      account_params: account_params,
      user_params:    user_params
    )
  end

  def valid_account_params
    { org_name: 'Alaska' }
  end

  def valid_user_params
    index =  User.maximum(:id)

    { username: "Alex_#{index}", email: "foo_#{index}@example.net", password: 'wild123' }
  end
end
