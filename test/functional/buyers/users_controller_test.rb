require 'test_helper'

class Buyers::UsersControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create :provider_account
    @buyer    = FactoryBot.create :buyer_account, provider_account: @provider
  end

  test 'activating a pending user' do
    user = FactoryBot.build :pending_user, account: @buyer, email: nil

    user.save validate: false

    login_provider @provider

    post :activate, params: { id: user.id, account_id: @buyer.id }

    assert_response :redirect
    assert_not_nil flash[:danger]
  end

  test 'activate a user creates onboarding process' do
    user = FactoryBot.build :pending_user, account: @buyer, email: 'the_user@buyer.example.com'

    user.save validate: false

    login_provider @provider

    assert_equal false, @buyer.onboarding.persisted?

    post :activate, params: { id: user.id, account_id: @buyer.id }

    assert_equal true, @buyer.reload.onboarding.persisted?
  end

  test 'email has been taken problem' do
    first_user  = FactoryBot.create :pending_user, account: @buyer, email: 'john@doe.example.net'
    second_user = FactoryBot.build :pending_user, account: @buyer, email: 'john@doe.example.net'

    second_user.save validate: false

    login_provider @provider

    post :activate, params: { id: first_user.id, account_id: @buyer.id }

    error_message = 'Failed to activate user: ' << I18n.t('errors.messages.duplicated_user_provider_side')

    assert_equal flash[:danger], error_message
  end

  test 'redirect back to the index page' do
    user      = FactoryBot.create :pending_user, account: @buyer, email: 'john@doe.example.net'
    index_url = 'http://multitenant-admin.3scale.net.dev:3000/buyers/accounts'

    login_provider @provider

    request.env['HTTP_REFERER'] = index_url

    post :activate, params: { id: user.id, account_id: @buyer.id }

    assert_redirected_to index_url
  end

  test 'redirect to the resource url if theres\'s no info about the previous request'  do
    user = FactoryBot.create :pending_user, account: @buyer, email: 'john@doe.example.net'

    login_provider @provider

    request.env['HTTP_REFERER'] = nil

    post :activate, params: { id: user.id, account_id: @buyer.id }

    assert_response :redirect
  end

  class EditPagePasswordFieldsTest < ActionController::TestCase
    tests Buyers::UsersController

    def setup
      @provider = FactoryBot.create(:provider_account)
      @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      @user = @buyer.admins.first
      host! @provider.internal_admin_domain
      login_provider @provider
    end

    test 'edit page shows password fields for user with password' do
      get :edit, params: { account_id: @buyer.id, id: @user.id }

      assert_response :success
      assert_select 'input[name="user[password]"]'
      assert_select 'input[name="user[password_confirmation]"]'
    end

    test 'edit page shows password fields for SSO user without password' do
      @user.update_columns(password_digest: nil, authentication_id: 'sso-user-id')

      get :edit, params: { account_id: @buyer.id, id: @user.id }

      assert_response :success
      assert_select 'input[name="user[password]"]'
      assert_select 'input[name="user[password_confirmation]"]'
    end
  end
end
