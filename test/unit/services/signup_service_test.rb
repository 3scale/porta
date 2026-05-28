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
    # invalid parameters
    service = new_instance_signup_service
    assert_difference(User.method(:count), 0) do
      result = service.create
      assert_not result.user.persisted?
      assert_not result.user.persisted?
      assert_not_empty result.errors[:user]
      assert_not_empty result.errors[:account]
    end

    # valid parameters
    service = new_instance_signup_service
    assert_difference(User.method(:count), +1) do
      user_params = valid_user_params
      account_params = valid_account_params
      result = service.create(account_params:, user_params:)
      assert result.persisted?
      assert_empty result.errors
      user = result.user
      account = result.account
      assert_equal :new_signup, user.signup_type
      assert_equal account_params[:org_name], account.org_name
      assert_equal user_params[:username], user.username
      assert_equal user_params[:email], user.email
    end

    service = new_instance_signup_service
    assert_difference(User.method(:count), +1) do
      result = service.create(account_params: valid_account_params, user_params: valid_user_params) { |_signup| [] }
      assert result.persisted?
    end

    service = new_instance_signup_service
    assert_difference(User.method(:count), 0) do
      service.create(account_params: valid_account_params, user_params: valid_user_params) { |signup| @signup = signup; break }
      assert_not @signup.persisted?
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

    { username: "Alex_#{index}", email: "foo_#{index}@example.net", password: 'superSecret1234#' }
  end
end
