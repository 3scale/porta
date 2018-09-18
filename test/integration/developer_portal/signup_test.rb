require 'test_helper'

class DeveloperPortal::SignupTest < ActionDispatch::IntegrationTest
  include DeveloperPortal::Engine.routes.url_helpers
  include UserDataHelpers

  def setup
    @provider = FactoryGirl.create(:provider_account)

    host! @provider.domain
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

  def test_signup_with_oauth_if_account_requires_approval
    @provider.settings.update_attributes(account_approval_required: true)

    @auth = FactoryGirl.create(:authentication_provider, published: true, account: @provider)
    stub_user_data({uid: '12345', email: 'foo@example.edu', email_verified: true}, stubbed_method: :authenticate!)

    post session_path(system_name: @auth.system_name, code: 'alaska')
    assert_redirected_to signup_path

    post(signup_path, {account: {
        org_name:   'alaska',
        user: {
            email:    'foo@example.edu',
            username: 'supertramp',
        }
    }})

    user = @provider.buyer_users.find_by!(email: 'foo@example.edu')
    assert user.active?
    refute user.can_login?
    assert_redirected_to success_signup_path
  end

  def test_show
    get signup_path

    assert_response :success

    get signup_path, plan_ids: ''

    assert_response :success

    get signup_path, plan_ids: nil

    assert_response :success

    get signup_path, plan_ids: []

    assert_response :success

    plan_id = @provider.provided_plans.published.first.id

    get signup_path, plan_ids: plan_id

    assert_response :success

    get signup_path, plan_ids: Array(plan_id)

    assert_response :success
  end
end
