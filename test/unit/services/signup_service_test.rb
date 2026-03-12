require 'test_helper'

class SignupServiceTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    store = stub('store', load_session: [1, {}], session_exists?: true)
    @session = ActionDispatch::Request::Session.create(store, ActionDispatch::Request.empty, {})
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

    service = new_instance_signup_service
    assert_difference(User.method(:count), +1) do
      user = service.create(account_params: valid_account_params, user_params: valid_user_params)
      assert user.persisted?
    end

    service = new_instance_signup_service
    assert_difference(User.method(:count), +1) do
      signup = service.create(account_params: valid_account_params, user_params: valid_user_params) { |_signup| [] }
      assert signup.persisted?
    end

    service = new_instance_signup_service
    assert_difference(User.method(:count), 0) do
      service.create(account_params: valid_account_params, user_params: valid_user_params) { |signup| @signup = signup; break }
      refute @signup.persisted?
    end
  end

  private

  def new_instance_signup_service
    SignupService.new(
      provider:       @provider,
      plans:          [],
      session:        @session
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
