# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::User::AccessTokensControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    @admin = @provider.admins.first

    host! @provider.external_admin_domain
    login_as @admin
  end

  test 'index renders the tokens list' do
    get :index

    assert_response :success
    assert_template 'index'
  end

  test 'index falls back to normal index when flash[:token] references a nonexistent token' do
    get :index, flash: { token: 'nonexistent' }

    assert_response :success
    assert_template 'index'
  end

  test 'index does not expose tokens from other users' do
    other_user = FactoryBot.create(:simple_user, account: @provider)
    other_token = FactoryBot.create(:access_token, owner: other_user)

    get :index, flash: { token: other_token.id }

    assert_response :success
    assert_template 'index'
  end

  test 'show is rendered when a token is created' do
    expires_at = 1.week.from_now.utc.iso8601
    post :create, params: { access_token: { name: 'Le Token', scopes: ['account_management'], permission: 'ro', expires_at: } }

    assert_response :success
    assert_template :show
  end
end
