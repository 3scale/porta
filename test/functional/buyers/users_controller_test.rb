require 'test_helper'

class Buyers::UsersControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryGirl.create :provider_account
    @buyer    = FactoryGirl.create :buyer_account, provider_account: @provider
  end

  test 'activating a pending user' do
    user = Factory.build :pending_user, account: @buyer, email: nil

    user.save validate: false

    login_provider @provider

    post :activate, { id: user.id, account_id: @buyer.id }

    assert_response :redirect
    assert_not_nil flash[:error]
  end

  test 'activate a user creates onboarding process' do
    user = Factory.build :pending_user, account: @buyer, email: 'the_user@buyer.example.com'

    user.save validate: false

    login_provider @provider

    assert_equal false, @buyer.onboarding.persisted?

    post :activate, { id: user.id, account_id: @buyer.id }

    assert_equal true, @buyer.reload.onboarding.persisted?
  end

  test 'email has been taken problem' do
    first_user  = Factory.create :pending_user, account: @buyer, email: 'john@doe.example.net'
    second_user = Factory.build :pending_user, account: @buyer, email: 'john@doe.example.net'

    second_user.save validate: false

    login_provider @provider

    post :activate, { id: first_user.id, account_id: @buyer.id }

    error_message = 'Failed to activate user: ' << I18n.t('errors.messages.duplicated_user_provider_side')

    assert_equal flash[:error], error_message
  end

  test 'redirect back to the index page' do
    user      = Factory.create :pending_user, account: @buyer, email: 'john@doe.example.net'
    index_url = 'http://multitenant-admin.3scale.net.dev:3000/buyers/accounts'

    login_provider @provider

    request.env['HTTP_REFERER'] = index_url

    post :activate, { id: user.id, account_id: @buyer.id }

    assert_redirected_to index_url
  end

  test 'redirect to the resource url if theres\'s no info about the previous request'  do
    user = Factory.create :pending_user, account: @buyer, email: 'john@doe.example.net'

    login_provider @provider

    request.env['HTTP_REFERER'] = nil

    post :activate, { id: user.id, account_id: @buyer.id }

    assert_response :redirect
  end
end
