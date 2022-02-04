# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Account::EmailConfigurationsControllerTest < ActionDispatch::IntegrationTest
  attr_reader :current_account

  class FeatureAvailableTest < self
    class MasterLoggedInTest < FeatureAvailableTest
      def setup
        super
        Features::EmailConfigurationConfig.stubs(enabled?: true)
        @current_account = master_account
        login! current_account
      end
    end

    test '#index' do
      get provider_admin_account_email_configurations_path
      assert_response :success
    end

    test '#new' do
      get new_provider_admin_account_email_configuration_path
      assert_response :success
    end

    test '#create' do
      assert_difference EmailConfiguration.method(:count) do
        post provider_admin_account_email_configurations_path, params: email_configurations_params
      end
      assert_response :redirect
      assert_equal email_configurations_params.dig(:email_configuration, :email), EmailConfiguration.last.email
    end

    test '#edit' do
      email_configuration = FactoryBot.create(:email_configuration, account: current_account)
      get edit_provider_admin_account_email_configuration_path(email_configuration)
      assert_response :success
    end

    test '#update' do
      email_configuration = FactoryBot.create(:email_configuration, account: current_account, user_name: 'Old username')
      put provider_admin_account_email_configuration_path(email_configuration), params: { email_configuration: { user_name: 'New username'} }
      assert_response :redirect

      assert_equal 'New username', email_configuration.reload.user_name
    end

    test '#delete' do
      email_configuration = FactoryBot.create(:email_configuration, account: current_account)

      delete provider_admin_account_email_configuration_path(email_configuration)
      assert_response :redirect

      assert_raises(ActiveRecord::RecordNotFound) { email_configuration.reload }
    end
  end

  class FeatureUnavailableTest < self
    class MasterLoggedInFeatureOffTest < FeatureUnavailableTest
      def setup
        super
        Features::EmailConfigurationConfig.stubs(enabled?: false)
        @current_account = master_account
        login! current_account
      end
    end

    class ProviderLoggedInTest < FeatureUnavailableTest
      def setup
        super
        Features::EmailConfigurationConfig.stubs(enabled?: true)
        @current_account = FactoryBot.create(:provider_account)
        login! current_account
      end
    end

    test '#index' do
      get provider_admin_account_email_configurations_path
      assert_response :not_found
    end

    test '#create' do
      post provider_admin_account_email_configurations_path, params: email_configurations_params
      assert_response :not_found
    end

    test '#new' do
      get new_provider_admin_account_email_configuration_path
      assert_response :not_found
    end

    test '#edit' do
      email_configuration = FactoryBot.create(:email_configuration)
      get edit_provider_admin_account_email_configuration_path(email_configuration)
      assert_response :not_found
    end

    test '#update' do
      email_configuration = FactoryBot.create(:email_configuration, user_name: 'Old username')
      put provider_admin_account_email_configuration_path(email_configuration), params: { user_name: 'New username'}
      assert_response :not_found
    end

    test '#delete' do
      email_configuration = FactoryBot.create(:email_configuration)
      delete provider_admin_account_email_configuration_path(email_configuration)
      assert_response :not_found

      assert email_configuration.reload
    end
  end

  def self.runnable_methods
    [FeatureUnavailableTest, FeatureAvailableTest].include?(self) ? [] : super
  end

  def email_configurations_params
    { email_configuration: { email: 'myemail@example.com', user_name: 'My Username', password: '123456' } }
  end
end
