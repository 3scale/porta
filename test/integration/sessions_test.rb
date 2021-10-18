# frozen_string_literal: true

require 'test_helper'

class SessionsTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create :provider_account
    @buyer    = FactoryBot.create(:buyer_account, :provider_account => @provider)
  end

  test '#create' do
    provider_user = FactoryBot.create(:user, account: @provider)
    provider_user.activate!

    Authentication::Strategy::ProviderOauth2.any_instance.expects(:authenticate).returns(provider_user)

    open_session do |session|
      session.host! @provider.admin_domain
      session.get provider_sso_path

      session.assert_response :redirect
      session.assert_equal provider_user, User.current
    end
  end

  test 'sso end-to-end integration' do
    host! @provider.admin_domain

    post(admin_api_sso_tokens_path, params: { :format => :xml, :provider_key => @provider.api_key, :user_id => @buyer.users.first.id, :expires_in => 6000 })

    assert_response :created

    xml = Nokogiri::XML::Document.parse response.body

    url = xml.css("sso_url").text

    host! @provider.domain

    get url

    assert_response :redirect
    assert_equal @buyer.users.first, User.current
  end

  test 'sso user_id has precedence over username if both passed in' do
    user_id  = @buyer.users.first!.id

    user = FactoryBot.create(:user, :account => @buyer, :username => 'someuser')

    host! @provider.admin_domain

    post(admin_api_sso_tokens_path, params: { :format => :xml, :provider_key => @provider.api_key, :user_id => user_id, :username => user.username, :redirect_url => forum_path(:host => @provider.domain) })

    assert_response :created

    xml = Nokogiri::XML::Document.parse response.body

    url = xml.css("sso_url").text

    host! @provider.domain

    get url

    assert_response :redirect
    assert_equal @buyer.users.first, User.current
  end

  test "sso end-to-end with username and without expires_in" do
    host! @provider.admin_domain

    post(admin_api_sso_tokens_path, params: { :format => :xml, :provider_key => @provider.api_key, :username => @buyer.users.first.username })

    assert_response :created

    xml = Nokogiri::XML::Document.parse response.body

    url = xml.css("sso_url").text

    host! @provider.domain

    get url

    assert_response :redirect
    assert_equal @buyer.users.first, User.current
  end

  test 'attempt to login with invalid token' do
    host! @provider.domain

    get developer_portal.create_session_path(:token => "token", :expires_at => Time.now.utc + 300)

    assert_response :success
    assert_template "login/new"
    assert_not_nil flash[:error]
    assert_nil User.current
  end

  test 'redirect_url parameter is discarded if login is not via sso' do
    user= FactoryBot.create(:user, :account => @buyer, :username => "xi@example.net", :password => "wwwwww")
    user.activate

    host! @provider.domain

    get_via_redirect developer_portal.create_session_url(:username => user.username, :password => "wwwwww", :redirect_url => forum_url(:host => @provider.domain))

    assert_equal root_path, path
  end

  test 'passing redirect_url with sso' do

    user= FactoryBot.create(:user, :account => @buyer, :username => "xi@example.net", :password => "wwwwww")
    user.activate

    Authentication::Strategy::Internal.any_instance.expects(:authenticate_with_sso).with('yabadabado', '2016').returns(user)

    host! @provider.domain

    get_via_redirect developer_portal.create_session_url(:token => 'yabadabado', :expires_at => '2016', :redirect_url => forum_url(:host => @provider.domain))

    assert_equal forum_path, path
  end

  test 'passing redirect_to to login form' do
    user= FactoryBot.create(:user, :account => @buyer, :username => "xi@example.net", :password => "password")
    user.activate

    host! @provider.domain

    get developer_portal.login_path(return_to: '/some-page')
    post developer_portal.session_path(username: 'xi@example.net', password:'password')

    assert_redirected_to '/some-page'
    assert_equal user, User.current
  end

  test 'passing redirect_to to outside domain' do
    user= FactoryBot.create(:user, :account => @buyer, :username => "xi@example.net", :password => "password")
    user.activate

    host! @provider.domain
    get developer_portal.login_path(return_to: 'http://example.com/some-page')
    post developer_portal.session_path(username: 'xi@example.net', password:'password')

    assert_redirected_to "http://#{@provider.domain}/some-page"
    assert_equal user, User.current
  end

  test 'current user is not persisted across domains' do
    provider_user = FactoryBot.create(:user, :account => @provider,
                              :username => 'provider', :password => 'provider')
    provider_user.activate!

    open_session do |session|
      session.host! @provider.admin_domain
      session.post provider_sessions_path(:username => 'provider', :password => 'provider')

      session.assert_response :redirect
      session.assert_equal provider_user, User.current
    end

    open_session do |session|
      session.host! @provider.domain
      session.get '/login'

      session.assert_response :success
      session.assert_nil User.current
    end
  end

  test 'mixpanel event properties are not persisted across requests' do
    provider_user = FactoryBot.create(:user, :account => @provider,
                            :username => 'provider', :password => 'provider')
    provider_user.activate!

    other_provider_user = FactoryBot.create(:user, :account => @provider,
                                  :username => 'other_provider', :password => 'provider')
    other_provider_user.activate!

    analytics = sequence('analytics calls')

    segment = ThreeScale::Analytics::UserTracking::Segment

    open_session do |session|
      segment
        .expects(:track)
        .in_sequence(analytics)
        .with { |params| params[:user_id] == provider_user.id }

      session.host! @provider.admin_domain
      session.post provider_sessions_path(:username => 'provider', :password => 'provider')

      session.assert_response :redirect
    end

    open_session do |session|
      segment
        .expects(:track)
        .in_sequence(analytics)
        .with { |params| params[:user_id] == other_provider_user.id }

      session.host! @provider.admin_domain
      session.post provider_sessions_path(:username => 'other_provider', :password => 'provider')

      session.assert_response :redirect
    end
  end

  test 'logout if authentication token is invalid' do
    host! @provider.admin_domain
    user = @provider.admins.first

    provider_login_with user.username, 'supersecret'
    assert_equal 1, user.user_sessions.count

    assert_no_difference '@provider.reload.updated_at' do
      with_forgery_protection { put provider_admin_account_path, params: { account: {org_name: 'jose'} } }
    end

    assert_redirected_to provider_login_url

    pre_org_name = @provider.org_name
    assert_equal pre_org_name, @provider.reload.org_name
    refute cookies["user_session"].present?
    assert_equal 1, user.user_sessions.count
    assert user.user_sessions.first.revoked_at
  end

  test 'change password deletes all but one user session in provider side' do

    user = @provider.admins.first
    user.user_sessions.create

    host! @provider.admin_domain
    provider_login_with user.username, 'supersecret'
    assert_equal 2, user.user_sessions.count
    put provider_admin_user_personal_details_path, params: { user: {current_password: 'supersecret' ,
                                                              password: 'newpwd',
                                                              username: 'test',
                                                              email: 'test2@example.com'} }

    assert_equal 1, user.user_sessions.count
  end

  test 'change password deletes all but one user session in buyer side' do

    user = @provider.buyers.first.users.first
    user.user_sessions.create

    host! @provider.domain
    login_with user.username, 'supersecret'
    assert_equal 2, user.user_sessions.count
    put '/admin/account/personal_details', params: { user: {current_password: 'supersecret' ,
                                                     password: 'newpwd',
                                                     username: 'test',
                                                     email: 'test2@example.com'} }

    assert_equal 1, user.user_sessions.count
  end

end
