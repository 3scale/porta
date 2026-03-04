require 'test_helper'

class Partners::UsersControllerTest < ActionController::TestCase

  def setup
    host! master_account.external_domain
    @partner = FactoryBot.create(:partner)
    @account = FactoryBot.create(:simple_provider, partner: @partner)
  end

  test 'create user' do
    post :create, params: { provider_id: @account.id, api_key: @partner.api_key, email: "foo@example.net", first_name: "foo_name", last_name: "foo_last_name", open_id: "bar_id", username: "aaron" }

    user = assigns(:user)

    assert user.valid?
    assert_equal @account, user.account
    assert_equal "foo@example.net", user.email
    assert_equal "foo_name", user.first_name
    assert_equal "foo_last_name", user.last_name
    assert_equal "bar_id", user.open_id
    assert_equal "aaron", user.username

    assert_equal "active", user.state

    body = JSON.parse(response.body)
    assert body['success']
  end

  test 'show user' do
    user = FactoryBot.create(:simple_user, account: @account, open_id: "lalala")
    get :show, params: { provider_id: @account.id, api_key: @partner.api_key, id: user.id }
    body = JSON.parse(response.body)

    assert_equal "lalala", body["user"]["open_id"]
  end

  test 'find a user by open_id' do
    user = FactoryBot.create(:simple_user, account: @account, open_id: "abcde")

    get :index, params: { provider_id: @account.id, api_key: @partner.api_key, open_id: "abcde" }

    users = assigns(:users)

    assert_equal user, users.first
  end

  test 'delete a user' do
    user = FactoryBot.create(:simple_user, account: @account)

    delete :destroy, params: { provider_id: @account.id, api_key: @partner.api_key, id: user.id }

    refute User.find_by_id(user.id)
    assert JSON.parse(response.body)
  end

  test 'create user without password but with open_id' do
    post :create, params: { provider_id: @account.id, api_key: @partner.api_key, email: "foo@example.net", username: "aaron", open_id: "sso-id" }

    assert_response :success
    user = assigns(:user)

    assert user.valid?
    assert_nil user.password_digest, 'User should have no password when not provided'
    assert_not user.already_using_password?, 'User should not be using password'
    assert_equal "sso-id", user.open_id

    body = JSON.parse(response.body)
    assert body['success']
  end

  test 'create user with password' do
    post :create, params: { provider_id: @account.id, api_key: @partner.api_key, email: "foo@example.net", username: "aaron", password: "superSecret1234#" }

    assert_response :success
    user = assigns(:user)

    assert user.valid?
    assert user.authenticated?("superSecret1234#"), 'User should authenticate with provided password'

    body = JSON.parse(response.body)
    assert body['success']
  end

  test 'create user with invalid params returns 422' do
    post :create, params: { provider_id: @account.id, api_key: @partner.api_key, email: "invalid-email", username: "aaron" }

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)

    assert_not body['success']
    assert body['errors'].present?
  end

  test 'create user with weak password rejected when strong passwords enabled' do
    post :create, params: { provider_id: @account.id, api_key: @partner.api_key, email: "foo@example.net", username: "aaron", password: "weakpwd" }

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)

    assert_not body['success']
    assert body['errors']['password'].present?
  end

  test 'create user with strong password accepted when strong passwords enabled' do
    post :create, params: { provider_id: @account.id, api_key: @partner.api_key, email: "foo@example.net", username: "aaron", password: "superSecret1234#" }

    assert_response :success
    user = assigns(:user)

    assert user.valid?
    assert user.authenticated?("superSecret1234#")

    body = JSON.parse(response.body)
    assert body['success']
  end
end
