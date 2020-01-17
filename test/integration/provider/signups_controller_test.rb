# frozen_string_literal: true

require 'test_helper'

class Provider::SignupsControllerTest < ActionDispatch::IntegrationTest
  def setup
    login! master_account
  end

  test 'POST creates a provider' do
    assert_difference(master_account.buyer_accounts.method(:count)) do
      post provider_signup_path, create_params
    end

    assert_redirected_to success_provider_signup_path

    provider = master_account.buyer_accounts.last!
    assert (user = provider.admin_users.but_impersonation_admin.first)

    create_params[:account].except(:user).each do |field_name, expected_value|
      assert_equal expected_value, provider.public_send(field_name)
    end

    create_params[:account][:user] do |field_name, expected_value|
      assert_equal expected_value, user.public_send(field_name)
    end
  end

  test 'POST without params' do
    assert_no_difference(master_account.buyer_accounts.method(:count)) do
      post provider_signup_path, {}
    end

    assert_response :bad_request
  end

  def create_params
    @create_params ||= {
      account: {
        name: 'organization name',
        user: {username: 'my username', email: 'email@example.com', password: '123456'}
      }
    }
  end
end
