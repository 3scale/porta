require 'test_helper'

class Partners::UsersControllerTest < ActionController::TestCase

  def setup
    @request.host = master_account.domain
    @partner = FactoryGirl.create(:partner)
    @account = FactoryGirl.create(:simple_provider, partner: @partner)
  end

  test 'create user' do
    post :create, provider_id: @account.id, api_key: @partner.api_key, email: "foo@example.net", first_name: "foo_name", last_name: "foo_last_name", open_id: "bar_id", username: "aaron"

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
    user = FactoryGirl.create(:simple_user, account: @account, open_id: "lalala")
    get :show, provider_id: @account.id, api_key: @partner.api_key, id: user.id
    body = JSON.parse(response.body)

    assert_equal "lalala", body["user"]["open_id"]
  end

  test 'find a user by open_id' do
    user = FactoryGirl.create(:simple_user, account: @account, open_id: "abcde")

    get :index, provider_id: @account.id, api_key: @partner.api_key, open_id: "abcde"

    users = assigns(:users)

    assert_equal user, users.first
  end

  test 'delete a user' do
    user = FactoryGirl.create(:simple_user, account: @account)

    delete :destroy, provider_id: @account.id, api_key: @partner.api_key, id: user.id

    refute User.find_by_id(user.id)
    assert JSON.parse(response.body)
  end


end
