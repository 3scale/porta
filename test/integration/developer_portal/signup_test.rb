# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::SignupTest < ActionDispatch::IntegrationTest
  include System::UrlHelpers.cms_url_helpers
  include UserDataHelpers

  def setup
    @provider = FactoryBot.create(:provider_account)

    host! @provider.internal_domain
  end

  def test_create
    post signup_path(account: {
      promo_code: '12345',
      org_name:   'alaska',
      user: {
        email:    'foo@example.edu',
        username: 'supertramp',
        password: 'westisthebest'
      }
    })

    assert_response :redirect
  end

  # A post request can't be sent directly to the controller bypassing the form
  # when the spam protection is always enabled.
  def test_create_spam_protected_always
    @provider.settings.update_attributes(spam_protection_level: :captcha)
    DeveloperPortal::SignupController.any_instance.stubs(:verify_captcha).returns(false)

    post signup_path(account: {
                       promo_code: '12345',
                       org_name:   'alaska',
                       user: {
                         email:    'foo@example.edu',
                         username: 'supertramp',
                         password: 'westisthebest'
                       }
                     })

    # The user wasn't created, so the spam protection worked
    user = @provider.buyer_users.find_by(email: 'foo@example.edu')
    assert_nil user
  end

  # A post request can't be sent directly to the controller bypassing the form
  # when the spam protection is set to suspicious only.
  def test_create_spam_protected_suspicious_only
    @provider.settings.update_attributes(spam_protection_level: :auto)
    DeveloperPortal::SignupController.any_instance.stubs(:verify_captcha).returns(false)

    post signup_path(account: {
                       promo_code: '12345',
                       org_name:   'alaska',
                       user: {
                         email:    'foo@example.edu',
                         username: 'supertramp',
                         password: 'westisthebest'
                       }
                     })

    # The user wasn't created, so the spam protection worked
    user = @provider.buyer_users.find_by(email: 'foo@example.edu')
    assert_nil user
  end

  def test_signup_with_oauth_if_account_requires_approval
    @provider.settings.update_attributes(account_approval_required: true) # rubocop:disable Rails/ActiveRecordAliases) This method is being overriden

    @auth = FactoryBot.create(:authentication_provider, published: true, account: @provider)
    stub_user_data({uid: '12345', email: 'foo@example.edu', email_verified: true}, stubbed_method: :authenticate!)

    post session_path(system_name: @auth.system_name, code: 'alaska')
    assert_redirected_to signup_path

    post signup_path, params: {
      account: {
        org_name: 'alaska',
        user: { email: 'foo@example.edu', username: 'supertramp' }
      }
    }

    user = @provider.buyer_users.find_by!(email: 'foo@example.edu')
    assert user.active?
    assert_not user.can_login?
    assert_redirected_to success_signup_path
  end

  def test_show
    get signup_path
    assert_response :success
  end

  def test_show_with_string
    get signup_path, params: { plan_ids: '' }
    assert_response :success
  end

  def test_show_with_nil
    get signup_path, params: { plan_ids: nil }
    assert_response :success
  end

  def test_show_with_empty_array
    get signup_path, params: { plan_ids: [] }
    assert_response :success
  end

  def test_show_with_id
    get signup_path, params: { plan_ids: @provider.provided_plans.published.first.id }
    assert_response :success
  end

  def test_show_with_array_of_ids
    get signup_path, params: { plan_ids: Array(@provider.provided_plans.published.first.id) }
    assert_response :success
  end
end
