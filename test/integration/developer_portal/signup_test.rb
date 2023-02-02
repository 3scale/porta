# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::SignupTest < ActionDispatch::IntegrationTest
  include System::UrlHelpers.cms_url_helpers
  include UserDataHelpers

  ACCOUNT_EMAIL = 'foo@example.edu'
  ACCOUNT = {
    promo_code: '12345',
    org_name:   'alaska',
    user: {
      email:    ACCOUNT_EMAIL,
      username: 'supertramp',
      password: 'westisthebest'
    }
  }.freeze

  def setup
    @provider = FactoryBot.create(:provider_account)

    host! @provider.internal_domain
  end

  class Create < DeveloperPortal::SignupTest
    module BypassForm
      def test_create_bypass_form_fails
        DeveloperPortal::SignupController.any_instance.stubs(:verify_captcha).returns(false)

        post signup_path(account: ACCOUNT)

        assert_empty User.by_email(ACCOUNT_EMAIL)
      end
    end

    class CreateCaptchaDisabled < Create
      def test_create
        post signup_path(account: ACCOUNT)

        assert_response :redirect
      end

      def test_signup_with_oauth_if_account_requires_approval
        @provider.settings.update_attributes(account_approval_required: true) # rubocop:disable Rails/ActiveRecordAliases) This method is being overriden

        @auth = FactoryBot.create(:authentication_provider, published: true, account: @provider)
        stub_user_data({uid: '12345', email: ACCOUNT_EMAIL, email_verified: true}, stubbed_method: :authenticate!)

        post session_path(system_name: @auth.system_name, code: 'alaska')
        assert_redirected_to signup_path

        post signup_path, params: {
          account: ACCOUNT
        }

        user = @provider.buyer_users.find_by!(email: ACCOUNT_EMAIL)
        assert user.active?
        assert_not user.can_login?
        assert_redirected_to success_signup_path
      end
    end

    class CreateCaptchaEnabled < Create
      def setup
        super
        @provider.settings.update(spam_protection_level: :captcha)
      end

      include BypassForm
    end

    class CreateCaptchaAuto < Create
      def setup
        super
        @provider.settings.update(spam_protection_level: :auto)
      end

      include BypassForm
    end
  end

  class Show < DeveloperPortal::SignupTest
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
end
