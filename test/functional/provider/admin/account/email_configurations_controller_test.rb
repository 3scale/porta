# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Account::EmailConfigurationsControllerTest < ActionController::TestCase
  test '#index' do
    get provider_admin_account_email_configurations_path
    assert_response :success
  end

  test '#create' do
    assert_difference EmailConfiguration.method(:count) do
      post provider_admin_account_email_configurations_path(format: :json), params: email_configurations_params
      assert_response :created
    end
  end

  test '#new' do
    get new_provider_admin_account_email_configuration_path
    assert_response :success
  end

  test '#edit' do
    email_configuration = FactoryBot.create(:email_configuration)
    get edit_provider_admin_account_email_configuration_path(email_configuration)
    assert_response :success
  end

  test '#update' do
    email_configuration = FactoryBot.create(:email_configuration)
    put provider_admin_account_email_configuration(email_configuration), params: email_configurations_params
    assert_response :success

    # TODO
  end

  test '#delete' do
    email_configuration = FactoryBot.create(:email_configuration)
    delete provider_admin_account_email_configuration(email_configuration)
    assert_response :deleted

    assert_nil email_configuration.reload
  end

  def email_configurations_params
    {}
  end
end
