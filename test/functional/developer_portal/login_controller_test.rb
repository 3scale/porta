require 'test_helper'

class DeveloperPortal::LoginControllerTest < DeveloperPortal::ActionController::TestCase

  include TestHelpers::FakeWeb

  test 'recognizes alternative create route' do
    assert_recognizes({:controller => 'developer_portal/login', :action => 'create'},
                      {:method => :get, :path => 'session/create'})
  end

  # {{{ CAS

  test 'cas is not displayed on login page' do
    provider_account = FactoryBot.create :provider_account
    provider_settings = provider_account.settings
    provider_settings.authentication_strategy = 'internal'
    provider_settings.save!
    @request.host = provider_account.domain

    get :new

    assert_response 200
    assert !@response.body.include?("CAS")
  end

  test 'cas is displayed on login page' do
    provider_account = FactoryBot.create :provider_account

    provider_settings = provider_account.settings
    provider_settings.authentication_strategy = 'cas'
    provider_settings.cas_server_url = "http://mamacit.as"
    provider_settings.save!
    @request.host = provider_account.domain

    get :new

    assert_response 200
    assert @response.body.include?("CAS")
  end

  test 'cas successful auth' do
    provider_account = FactoryBot.create :provider_account
    provider_settings = provider_account.settings
    provider_settings.authentication_strategy = 'cas'
    provider_settings.cas_server_url = "http://mamacit.as"
    provider_settings.save!

    buyer_account = FactoryBot.create :buyer_account, :provider_account => provider_account
    user = FactoryBot.create :user, :account  => buyer_account, :cas_identifier => "laurie"
    user.activate!
    user.save!

    @request.host = provider_account.domain

    res = stub :body => "yes\nlaurie", :code => 200
    HTTPClient.expects(:get).with(anything).returns(res)

    get :create, :ticket => "made-up"

    assert_redirected_to '/'

    assert_nil session[:user_id]
    assert_equal UserSession.authenticate(cookies.signed[:user_session]).user.id, user.id
  end

  test 'oauth2 successful authenticate for the first time using oauth2' do
    user

    authentication_provider = FactoryBot.create(:authentication_provider, account: provider_account, kind: 'base')
    @request.host = provider_account.domain

    mock_oauth2('oauth|1234', 'C6789', authentication_provider.user_info_url)

    assert_equal 0, user.sso_authorizations.count
    post :create, system_name: authentication_provider.system_name, code: 'C6789'
    assert_equal 'Signed in successfully', flash[:notice]
    assert_equal 'fake-id_token', user.sso_authorizations.last.id_token
  end

  test 'oauth2 successful authenticate and it is not the first time' do
    user

    authentication_provider = FactoryBot.create(:authentication_provider, account: provider_account, kind: 'base')
    @request.host = provider_account.domain

    user.sso_authorizations.create(authentication_provider: authentication_provider, uid: user.authentication_id, id_token: 'first-id_token')

    mock_oauth2(user.authentication_id, 'C6789', authentication_provider.user_info_url)

    assert_equal 'first-id_token', user.sso_authorizations.last.id_token
    post :create, system_name: authentication_provider.system_name, code: 'C6789'
    assert_equal 'Signed in successfully', flash[:notice]
    assert_equal 'fake-id_token', user.sso_authorizations.last.id_token
  end

  test 'oauth2 redirect to signup' do
    authentication_provider = FactoryBot.create(:authentication_provider, account: provider_account, kind: 'base')
    @request.host = provider_account.domain

    mock_oauth2('foo', 'C6789', authentication_provider.user_info_url)

    post :create, system_name: authentication_provider.system_name, code: 'C6789', plan_id: 42

    assert_redirected_to signup_path(plan_id: 42)
    assert_equal 'Successfully authenticated, please complete the signup form', flash[:notice]
    assert_equal 'fake-id_token', session[:id_token]
  end

  test 'disabled when account is suspended' do
    host! FactoryBot.create(:simple_provider, state: 'suspended').domain

    get :new

    assert_response :not_found
  end

  test 'ssl certificate error' do
    authentication_provider = FactoryBot.create(:authentication_provider, account: provider_account, kind: 'base')
    host! provider_account.domain

    client = mock
    client.stubs(:authenticate!).returns(ThreeScale::OAuth2::ErrorData.new(error: error = 'hostname "example.com" does not match the server certificate'))
    ThreeScale::OAuth2::Client.expects(build: client)
    post :create, system_name: authentication_provider.system_name, code: 'abcdefg1234567'
    assert_equal error, flash[:error]
  end

  def user
    @user ||= create_user_and_account
  end

  def provider_account
    @provider_account ||= create_oauth2_provider_account
  end

  def create_user_and_account
    buyer_account = FactoryBot.create(:buyer_account, provider_account: provider_account)
    FactoryBot.create(:user, account: buyer_account, password: 'kangaroo', state: 'active', authentication_id: 'oauth|1234')
  end

  def create_oauth2_provider_account
    provider_account = FactoryBot.create(:provider_account)
    provider_account.settings.update_attributes({authentication_strategy: 'oauth2'})
    provider_account
  end
end
