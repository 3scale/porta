require 'test_helper'

class DeveloperPortal::LoginTest < ActionDispatch::IntegrationTest
  include System::UrlHelpers.cms_url_helpers
  include UserDataHelpers
  include ActiveJob::TestHelper

  def setup
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:simple_buyer, provider_account: @provider)
    @user = FactoryBot.create(:user, account: @buyer, authentication_id: 'bar')
    @auth = FactoryBot.create(:authentication_provider, account: @provider, kind: 'base')

    @user.activate!
    host! @provider.internal_domain
  end

  def teardown
    ActionMailer::Base.deliveries.clear
  end

  def test_create
    # user is using the old method of authentication
    assert_equal 0, @user.sso_authorizations.count
    assert_not_empty @user.authentication_id

    # user should be identified by old authentication method
    stub_user_data(authentication_id: @user.authentication_id, uid: 'new-uid')
    stub_oauth2_request
    post session_path(system_name: @auth.system_name, code: 'example')
    assert_equal 'Signed in successfully', flash[:notice]

    get logout_path
    assert_response :redirect

    # user should be migrated to new sso
    @user.reload
    assert_nil @user.authentication_id
    assert_equal 1, @user.sso_authorizations.count

    # user should be identified by new sso authorization method
    @user.reload
    stub_user_data(uid: @user.sso_authorizations.last.uid)
    stub_oauth2_request
    post session_path(system_name: @auth.system_name, code: 'example')
    assert_equal 'Signed in successfully', flash[:notice]

    @user.sso_authorizations.destroy_all

    # user should not be identified by not confirmed email address
    stub_user_data(uid: 'new-uid', email: @user.email, email_verified: false)
    stub_oauth2_request
    post session_path(system_name: @auth.system_name, code: 'example')
    assert_equal 'Successfully authenticated, please complete the signup form', flash[:notice]
    @user.reload
    assert_equal 0, @user.sso_authorizations.count

    # user should be identified by confirmed email address
    stub_user_data(uid: 'new-uid', email: @user.email, email_verified: true)
    stub_oauth2_request
    post session_path(system_name: @auth.system_name, code: 'example')
    assert_equal 'Signed in successfully', flash[:notice]
    @user.reload
    assert_equal 1, @user.sso_authorizations.count

    get logout_path
    assert_response :redirect

    # user should be identified by new sso authorization method
    @user.reload
    stub_user_data(uid: @user.sso_authorizations.first.uid)
    stub_oauth2_request
    post session_path(system_name: @auth.system_name, code: 'example')
    assert_equal 'Signed in successfully', flash[:notice]
    @user.reload
    assert_equal 1, @user.sso_authorizations.count
  end

  def test_create_approval_required
    # account approval required is set to TRUE and NO sso integrations have automatically approve accounts feature turned on
    @provider.settings.update(account_approval_required: true)
    @provider.authentication_providers.update_all(automatically_approve_accounts: false)
    stub_user_data(uid: 'uid1', email: 'foo@example.com', username: 'foo', org_name: 'company', email_verified: true)
    stub_oauth2_request
    perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      post session_path(system_name: @auth.system_name, code: 'example')
    end
    assert_match "Your account isn't active or hasn't been approved yet.", flash[:error]
    assert_match 'email once we have approved your account', waiting_list_confirmation_email('foo@example.com').body.to_s
    user = @provider.buyer_users.find_by_email('foo@example.com')
    assert user.active?
    assert user.account.pending?

    # account approval required is set to TRUE and ALL sso integrations have automatically approve accounts feature turned on
    @provider.authentication_providers.update_all(automatically_approve_accounts: true)
    stub_user_data(uid: 'ud2', email: 'foo2@example.com', username: 'foo2', org_name: 'company2', email_verified: true)
    stub_oauth2_request
    post session_path(system_name: @auth.system_name, code: 'example')
    assert_match 'Signed up successfully', flash[:notice]
    assert_nil waiting_list_confirmation_email('foo2@example.com')
    user_2 = @provider.buyer_users.find_by_email('foo2@example.com')
    assert user_2.active?
    assert user_2.account.approved?

    # account approval required is set to FALSE and NO sso integrations have automatically approve accounts feature turned on
    @provider.settings.update(account_approval_required: false)
    @provider.authentication_providers.update_all(automatically_approve_accounts: false)
    stub_user_data(uid: 'ud3', email: 'foo3@example.com', username: 'foo3', org_name: 'company3', email_verified: true)
    stub_oauth2_request
    post session_path(system_name: @auth.system_name, code: 'example')
    assert_match 'Signed up successfully', flash[:notice]
    assert_nil waiting_list_confirmation_email('foo3@example.com')
    user_3 = @provider.buyer_users.find_by_email('foo2@example.com')
    assert user_3.active?
    assert user_3.account.approved?
  end

  def test_create_activation
    @provider.settings.update(account_approval_required: true)
    @provider.authentication_providers.update_all(automatically_approve_accounts: true)
    stub_user_data(uid: 'ud2', email: 'foo2@example.com', org_name: 'company', email_verified: true)
    stub_oauth2_request
    post session_path(system_name: @auth.system_name, code: 'example')
    assert_match 'Successfully authenticated, please complete the signup form', flash[:notice]
    post signup_path(account: {
      org_name: 'company',
      user: {
        email: 'foo2@example.com',
        username: 'username',
        password: 'superSecret1234#'
      }
    })

    user = @provider.buyer_users.find_by_email('foo2@example.com')
    assert user.account.approved?
    assert_match 'Signed up successfully', flash[:notice]
    assert_nil waiting_list_confirmation_email('foo2@example.com')
  end

  test 'create with invalid or empty CSRF token' do
    with_forgery_protection { post session_path(system_name: @auth.system_name, code: 'example') }
    assert_response :forbidden

    System::ErrorReporting.expects(:report_error).once.with do |exception|
      exception.is_a?(ActionController::InvalidAuthenticityToken)
    end
    with_forgery_protection { post session_path(system_name: @auth.system_name, code: 'example', authenticity_token: 'invalid') }
    assert_response :forbidden
  end

  private

  def waiting_list_confirmation_email(email_address)
    ActionMailer::Base.deliveries.select do |email|
      email.to.include?(email_address) && email.subject == 'Waiting list confirmation'
    end.last
  end

  def stub_oauth2_request
    mock_oauth2(@user.authentication_id, 'example', @auth.user_info_url)
  end
end
