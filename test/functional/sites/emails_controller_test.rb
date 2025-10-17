# frozen_string_literal: true

require 'test_helper'

class Sites::EmailsControllerTest < ActionController::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
    @admin = FactoryBot.create(:admin, account: @provider)
    @request.host = @provider.internal_admin_domain
  end

  class AuthorizationTest < Sites::EmailsControllerTest
    test 'provider required' do
      get :edit
      assert_redirected_to provider_login_url(host: @request.host)
    end

    test 'denies on premises for master' do
      login_as(@admin)
      ThreeScale.stubs(:master_on_premises?).returns true

      get :edit

      assert_response :forbidden
    end
  end

  class AuthenticatedTest < Sites::EmailsControllerTest
    def setup
      super
      login_as(@admin)
    end

    test 'edit' do
      get :edit

      assert_response :success
      assert_template :edit
    end

    test 'update account support email only' do
      patch :update, params: { account: { support_email: 'new@example.com' } }

      assert_redirected_to action: :edit
      assert_equal 'new@example.com', @provider.reload.support_email
      assert_equal 'new@example.com', @provider.reload.finance_support_email
      assert_equal 'Your support emails have been updated', flash[:success]
    end

    test 'update account and finance support emails' do
      patch :update, params: { account: { support_email: 'support@example.com',
                                          finance_support_email: 'finance@example.com' } }

      assert_redirected_to action: :edit
      assert_equal 'support@example.com', @provider.reload.support_email
      assert_equal 'finance@example.com', @provider.reload.finance_support_email
      assert_equal 'Your support emails have been updated', flash[:success]
    end

    test 'update with an invalid email' do
      patch :update, params: { account: { support_email: 'invalid-email',
                                          finance_support_email: 'also@wrong@.com' } }

      assert_response :success
      assert_template :edit
      assert_equal "Couldn't update your support emails", flash[:error]
      assert_not_equal 'invalid-email', @provider.reload.support_email
      assert_not_equal 'also@wrong@.com', @provider.finance_support_email
    end

    test 'update permitted params' do
      original_name = @provider.org_name
      patch :update, params: { account: { org_name: 'Hacked Name' } }

      assert_redirected_to action: :edit
      assert_equal original_name, @provider.reload.org_name
    end
  end
end
