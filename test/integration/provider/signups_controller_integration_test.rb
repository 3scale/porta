# frozen_string_literal: true

require 'test_helper'

class Provider::SignupsControllerIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    login! master_account
  end

  test 'disables x_frame_options header' do
    get provider_signup_path
    assert_not_includes response.headers, 'X-Frame-Options'
  end

  test 'POST creates a provider' do
    ThreeScale::Analytics::UserTracking.any_instance.expects(:track).at_least_once.with('Signup', {mkt_cookie: nil, analytics: {}})

    assert_difference(master_account.buyer_accounts.method(:count)) do
      post provider_signup_path, params: create_params({ account: { name: 'theorganization' } })
    end

    assert_redirected_to success_provider_signup_path

    provider = master_account.buyer_accounts.order(:id).last!
    assert(user = provider.admin_users.but_impersonation_admin.first)

    create_params[:account].except(:user).each do |field_name, expected_value|
      assert_equal expected_value, provider.public_send(field_name)
    end
    assert provider.sample_data
    assert_match /^theorganization(-\d+)?$/, provider.subdomain.to_s
    assert_match /^theorganization(-\d+)?-admin$/, provider.self_subdomain.to_s

    create_params[:account][:user].except(:password).each do |field_name, expected_value|
      assert_equal expected_value, user.public_send(field_name)
    end
    assert_equal :new_signup, user.signup_type
    assert_equal 'admin', user.username
  end

  test 'POST without params' do
    assert_no_difference(master_account.buyer_accounts.method(:count)) do
      post provider_signup_path
    end

    assert_response :bad_request
  end

  test 'POST in case of invalid params' do
    assert_no_difference(master_account.buyer_accounts.method(:count)) do
      post provider_signup_path, params: create_params({ account: { user: { email: 'invalid email' } } })
    end

    assert_response :success
  end

  test 'POST in case of spam check not passing' do
    Provider::SignupsController.any_instance.expects(:bot_check).returns(false)

    assert_no_difference(master_account.buyer_accounts.method(:count)) do
      post provider_signup_path, params: create_params
    end

    assert_response :success
  end

  test 'POST accepts the subdomain if given' do
    assert_difference(master_account.buyer_accounts.method(:count)) do
      post provider_signup_path, params: create_params({ account: { org_name: 'organization', subdomain: 'mysubdomain', self_subdomain: 'selfsubdomain-admin' } })
    end

    provider = master_account.buyer_accounts.order(:id).last!

    assert_equal 'organization', provider.name
    assert_equal 'mysubdomain', provider.subdomain
    assert_equal 'selfsubdomain-admin', provider.self_subdomain
  end

  def create_params(extra_params = {})
    @create_params ||= {
      account: {
        name: 'organization name',
        user: {email: 'email@example.com', password: 'superSecret1234#'}
      }
    }.deep_merge(extra_params)
  end
end

class Provider::SignupsControllerStrongPasswordsTest < ActionDispatch::IntegrationTest
  STRONG_PASSWORD = 'superSecret1234#'
  WEAK_PASSWORD = 'weakpwd'

  def setup
    host! master_account.external_admin_domain
  end

  def signup_params(password)
    {
      account: {
        name: 'organization name',
        user: { email: 'email@example.com', password: password }
      }
    }
  end

  def test_weak_password_rejected_when_strong_passwords_enabled
    assert_no_difference(master_account.buyer_accounts.method(:count)) do
      post provider_signup_path, params: signup_params(WEAK_PASSWORD)
    end

    assert_response :success
    assert_match "is too short (minimum is 15 characters)", response.body
  end

  def test_strong_password_accepted_when_strong_passwords_enabled
    assert_difference(master_account.buyer_accounts.method(:count)) do
      post provider_signup_path, params: signup_params(STRONG_PASSWORD)
    end

    assert_redirected_to success_provider_signup_path
  end

  def test_weak_password_accepted_when_strong_passwords_disabled
    Rails.configuration.three_scale.stubs(:strong_passwords_disabled).returns(true)

    assert_difference(master_account.buyer_accounts.method(:count)) do
      post provider_signup_path, params: signup_params(WEAK_PASSWORD)
    end

    assert_redirected_to success_provider_signup_path
  end
end
