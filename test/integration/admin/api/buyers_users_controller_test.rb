# frozen_string_literal: true

require 'test_helper'

class Admin::Api::BuyersUsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:simple_buyer, provider_account: provider)

    host! provider.external_admin_domain
  end

  attr_reader :provider, :buyer

  test 'creates a user for its buyer' do
    assert_difference(buyer.users.method(:count)) do
      post admin_api_account_users_path(buyer), params: params
    end

    user = buyer.users.order(created_at: :asc).last!
    params.except(:password, :access_token).each do |attr_name, expected_value|
      assert_equal expected_value, user.public_send(attr_name),
                   "#{attr_name} expected to be #{expected_value} but is #{user.public_send(attr_name)}"
    end
  end

  test 'updates a buyer user with password' do
    user = FactoryBot.create(:simple_user, account: buyer)

    put admin_api_account_user_path(buyer, user), params: { access_token: token_value, password: 'newPassword1234#' }

    assert_response :success
    assert user.reload.authenticated?('newPassword1234#'), 'User should authenticate with new password'
  end

  test 'update with weak password rejected when strong passwords enabled' do
    user = FactoryBot.create(:simple_user, account: buyer)

    put admin_api_account_user_path(buyer, user), params: { access_token: token_value, password: 'weakpwd' }

    assert_response :unprocessable_entity
    assert_match "is too short (minimum is 15 characters)", response.body
  end

  test 'update with strong password accepted when strong passwords enabled' do
    user = FactoryBot.create(:simple_user, account: buyer)

    put admin_api_account_user_path(buyer, user), params: { access_token: token_value, password: 'superSecret1234#' }

    assert_response :success
    assert user.reload.authenticated?('superSecret1234#'), 'User should authenticate with new password'
  end

  private

  def params
    @params ||= {
      access_token: token_value,
      username: 'testusername',
      email: 'test@example.com',
      password: 'superSecret1234#',
      first_name: 'testname',
      last_name: 'testsurname'
    }
  end

  def token_value
    @token_value ||= FactoryBot.create(:access_token, owner: provider.admin_user, scopes: 'account_management', permission: 'rw').value
  end
end
