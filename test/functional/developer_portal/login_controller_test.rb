require 'test_helper'

class DeveloperPortal::LoginControllerTest < DeveloperPortal::ActionController::TestCase
  test 'recognizes alternative create route' do
    assert_recognizes({:controller => 'developer_portal/login', :action => 'create'},
                      {:method => :get, :path => 'session/create'})
  end

  test 'cas is not displayed on login page' do
    provider_account = FactoryBot.create :provider_account
    provider_settings = provider_account.settings
    provider_settings.authentication_strategy = 'internal'
    provider_settings.save!
    host! provider_account.external_domain

    get :new

    assert_response 200
    # CAS visible outside a tag to avoid rare authenticity_token match
    assert_not_match />[^<>]*?CAS/, @response.body
  end

  test 'oauth2 successful authenticate for the first time using oauth2' do
    user

    authentication_provider = FactoryBot.create(:authentication_provider, account: provider_account, kind: 'base')
    host! provider_account.external_domain

    mock_oauth2('oauth|1234', 'C6789', authentication_provider.user_info_url)

    assert_equal 0, user.sso_authorizations.count
    post :create, params: { system_name: authentication_provider.system_name, code: 'C6789' }
    assert_equal 'Signed in successfully', flash[:notice]
    assert_equal 'fake-id_token', user.sso_authorizations.last.id_token
  end

  test 'oauth2 successful authenticate and it is not the first time' do
    user

    authentication_provider = FactoryBot.create(:authentication_provider, account: provider_account, kind: 'base')
    host! provider_account.external_domain

    user.sso_authorizations.create(authentication_provider: authentication_provider, uid: user.authentication_id, id_token: 'first-id_token')

    mock_oauth2(user.authentication_id, 'C6789', authentication_provider.user_info_url)

    assert_equal 'first-id_token', user.sso_authorizations.last.id_token
    post :create, params: { system_name: authentication_provider.system_name, code: 'C6789' }
    assert_equal 'Signed in successfully', flash[:notice]
    assert_equal 'fake-id_token', user.sso_authorizations.last.id_token
  end

  test 'oauth2 redirect to signup' do
    authentication_provider = FactoryBot.create(:authentication_provider, account: provider_account, kind: 'base')
    host! provider_account.external_domain

    mock_oauth2('foo', 'C6789', authentication_provider.user_info_url)

    post :create, params: { system_name: authentication_provider.system_name, code: 'C6789', plan_id: 42 }

    assert_redirected_to signup_path(plan_id: 42)
    assert_equal 'Successfully authenticated, please complete the signup form', flash[:notice]
    assert_equal 'fake-id_token', session[:id_token]
  end

  test 'disabled when account is suspended' do
    host! FactoryBot.create(:simple_provider, state: 'suspended').internal_domain

    get :new

    assert_response :not_found
  end

  test 'ssl certificate error' do
    authentication_provider = FactoryBot.create(:authentication_provider, account: provider_account, kind: 'base')
    host! provider_account.internal_domain

    client = mock
    client.stubs(:authenticate!).returns(ThreeScale::OAuth2::ErrorData.new(error: error = 'hostname "example.com" does not match the server certificate'))
    ThreeScale::OAuth2::Client.expects(build: client)
    post :create, params: { system_name: authentication_provider.system_name, code: 'abcdefg1234567' }
    assert_equal error, flash[:error]
  end

  test 'login fail generates an audit log' do
    buyer_account = FactoryBot.create :buyer_account
    buyer_settings = buyer_account.settings
    buyer_settings.authentication_strategy = 'internal'
    buyer_settings.save!
    user = buyer_account.admins.first

    AuditLogService.expects(:call).with { |msg| msg.start_with? "Login attempt failed" }

    host! buyer_account.provider_account.external_domain
    post :create, params: { username: user.username, password: 'wrong_pass' }
  end

  def user
    @user ||= create_user_and_account
  end

  def provider_account
    @provider_account ||= create_oauth2_provider_account
  end

  def create_user_and_account
    buyer_account = FactoryBot.create(:buyer_account, provider_account: provider_account)
    FactoryBot.create(:user, account: buyer_account, password: 'superSecret1234#', state: 'active', authentication_id: 'oauth|1234')
  end

  def create_oauth2_provider_account
    provider_account = FactoryBot.create(:provider_account)
    provider_account.settings.update({authentication_strategy: 'oauth2'})
    provider_account
  end
end
