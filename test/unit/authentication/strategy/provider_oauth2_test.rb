require 'test_helper'

class Authentication::Strategy::ProviderOauth2Test < ActiveSupport::TestCase

  setup do
    @provider = FactoryBot.create(:simple_provider)
    @provider.settings.update_column(:authentication_strategy, 'oauth2')
    @authentication_provider = FactoryBot.create(:self_authentication_provider, account: @provider, kind: 'base')
    @strategy = Authentication::Strategy.build_provider(@provider)
  end

  test '#authenticate when authentication fails' do
    system_name = @authentication_provider.system_name
    stub_request(:post, "http://example.com/oauth/token")

    # No raise error
    result = @strategy.authenticate({system_name: system_name, code: '1234', request: mock_request})
    refute result

    # No redirect to signup
    refute @strategy.redirects_to_signup?
  end

  test '#authenticate find user that can login' do
    system_name = @authentication_provider.system_name
    user = FactoryBot.create(:active_user, account: @provider, authentication_id: 'foobar')

    mock_client(@authentication_provider, uid: user.authentication_id)
    result = @strategy.authenticate({system_name: system_name, code: '1234', request: mock_request})
    assert_equal user, result
    refute @strategy.error_message.present?
    refute @strategy.redirects_to_signup?
  end

  test '#authenticate find activate pending user if the email was verified' do
    system_name = @authentication_provider.system_name
    user = FactoryBot.create(:pending_user, account: @provider, authentication_id: 'foobar', email: 'foo@example.com')

    mock_client(@authentication_provider, uid: user.authentication_id, email: 'foo@example.com')
    assert result = @strategy.authenticate({system_name: system_name, code: '1234', request: mock_request})

    assert user.reload.active?
  end

  test '#authenticate will create user' do
    mock_client(@authentication_provider, email: 'user@example.com', uid: 'someuid')
    assert user = @strategy.authenticate({system_name: @authentication_provider.system_name, code: '1234', request: mock_request})

    assert user.persisted?
    assert user.active?
    assert_equal 'user@example.com', user.email
  end

  test '#on_signup without nickname' do
    system_name = @authentication_provider.system_name

    mock_client(@authentication_provider, uid: 'foobar', username: nil)
    @strategy.authenticate({system_name: system_name, code: '1234', request: mock_request})

    session = {}
    @strategy.on_signup(session)

    assert_nil session[:authentication_username]
  end

  test '#on_signup with no trust email' do
    system_name = @authentication_provider.system_name

    mock_client(@authentication_provider, uid: 'foobar', email_verified: false)
    @strategy.authenticate({system_name: system_name, code: '1234', request: mock_request})

    session = {}
    @strategy.on_signup(session)
    assert_nil session[:authentication_email]
  end

  test '#on_signup without email' do
    system_name = @authentication_provider.system_name

    mock_client(@authentication_provider, uid: 'foobar', email: nil)
    @strategy.authenticate({system_name: system_name, code: '1234', request: mock_request})

    session = {}
    @strategy.on_signup(session)

    assert_nil session[:authentication_email]
  end

  test '#on_signup_complete should clear session authentication data' do
    session = { authentication_id: 'B5678' }

    user = FactoryBot.build(:user)
    @strategy.on_new_user(user, session)

    @strategy.on_signup_complete(session)
    assert_nil session[:authentication_id]
    assert_nil session[:authentication_email]
    assert_nil session[:authentication_username]
    assert_nil session[:authentication_kind]
  end

  test '#on_signup_complete when user email is the same as session authentication_email' do
    user    = FactoryBot.build(:user)
    session = {
      authentication_id: 'B5678',
      authentication_email: user.email,
      authentication_provider: @authentication_provider.system_name
    }
    @strategy.on_new_user(user, session)

    assert_difference("User.where('activated_at is not null').count", +1) do
      @strategy.on_signup_complete(session)
    end
  end

  test '#on_signup_complete when user email is different from session authentication_email' do
    user = FactoryBot.build(:user)
    session = { authentication_id: 'B5678', authentication_email: 'diferent@email.com' }
    @strategy.on_new_user(user, session)

    assert_difference("User.where('activated_at is not null').count", 0) do
      @strategy.on_signup_complete(session)
    end
  end

  test '#track_signup_options with oauth2' do
    user = FactoryBot.build(:user)
    session = {
      authentication_id: 'B5678',
      authentication_email: 'diferent@email.com',
      authentication_kind: 'github',
      authentication_provider: @authentication_provider.system_name
    }
    @strategy.on_new_user(user, session)

    expected_options = {kind: 'github', strategy: 'oauth2'}
    assert_equal(expected_options, @strategy.track_signup_options({session: session}))
  end

  test '#on_new_user' do
    user = User.new
    session = {
      authentication_id: 'C1234',
      authentication_email: 'foo@example.com',
      authentication_username: 'foobar',
      authentication_provider: @authentication_provider.system_name
    }

    # should assign data from session to user
    @strategy.on_new_user(user, session)

    assert_equal session[:authentication_id], user.sso_authorizations.last.uid
    assert_equal session[:authentication_email], user.email
    assert_equal session[:authentication_username], user.username
    assert_equal user, @strategy.user_for_signup

    # should not overrite the attributes of user

    old_attributes = user.attributes.clone
    session[:authentication_email] = 'other@example.com'
    session[:authentication_username] = 'other'
    @strategy.on_new_user(user, session)
    refute_equal old_attributes[:email], user.email
    refute_equal old_attributes[:username], user.username
  end

  class SsoSignupTest < ActiveSupport::TestCase

    disable_transactional_fixtures!

    test 'create an active user through sso' do
      authentication_provider = FactoryBot.create(:self_authentication_provider, account: oauth2_provider, kind: 'base')
      authentication_strategy = Authentication::Strategy.build_provider(oauth2_provider)

      client    = mock('client')
      user_data = valid_user_data
      client.stubs(authenticate!: user_data)
      ThreeScale::OAuth2::Client.expects(:build).with(authentication_provider).returns(client).once

      assert_difference(User.method(:count), +1) do
        result = authentication_strategy.authenticate({
          system_name: authentication_provider.system_name,
          code:        '1234',
          request:     mock_request
        })

        assert_instance_of User, result
        assert_equal result.email, user_data[:email]
        assert_equal result.username, user_data[:username]
        assert_equal [authentication_provider.id], result.sso_authorizations.pluck(:authentication_provider_id)

        assert result.active?
        assert authentication_strategy.error_message.blank?
        assert authentication_strategy.new_user_created?
      end

      last_email = ActionMailer::Base.deliveries.last
      assert_match 'Account Activation', last_email.subject
      assert_match 'activate your account', last_email.body.to_s
    end

    test 'create a non active user through sso' do
      authentication_provider = FactoryBot.create(:self_authentication_provider, account: oauth2_provider, kind: 'base')
      authentication_strategy = Authentication::Strategy.build_provider(oauth2_provider)

      client    = mock('client')
      user_data = valid_user_data(email_verified: false)
      client.stubs(authenticate!: user_data)
      ThreeScale::OAuth2::Client.expects(:build).with(authentication_provider).returns(client).once

      deliveries = ActionMailer::Base.deliveries

      assert_difference(User.method(:count), +1) do

        assert_difference deliveries.method(:size) do
          refute authentication_strategy.authenticate({
                                                          system_name: authentication_provider.system_name,
                                                          code:        '1234',
                                                          request:     mock_request
                                                        })
        end

        assert authentication_strategy.error_message.present?
        assert authentication_strategy.new_user_created?

      end

      last_email = deliveries.last

      assert_match 'Account Activation', last_email.subject
      assert_match 'activate your account', last_email.body.to_s
    end

    test 'CreateInvitedUser' do
      authentication_provider = FactoryBot.create(:self_authentication_provider, account: oauth2_provider, kind: 'base')
      authentication_strategy = Authentication::Strategy.build_provider(oauth2_provider)

      invitation = FactoryBot.create(:invitation, account: oauth2_provider)
      client     = mock('client')
      user_data  = valid_user_data
      client.stubs(authenticate!: user_data)
      ThreeScale::OAuth2::Client.expects(:build).with(authentication_provider).returns(client).once

      assert_difference(User.method(:count), +1) do
        result = authentication_strategy.authenticate({
          system_name: authentication_provider.system_name,
          code:        '1234',
          request:     mock_request,
          invitation:  invitation
        }, procedure:  Authentication::Strategy::Oauth2::CreateInvitedUser)

        assert_instance_of User, result
        assert_equal result.email, user_data[:email]
        assert_equal result.username, user_data[:username]
        assert result.active?
        assert authentication_strategy.error_message.blank?
        assert_not_match 'confirmation', ActionMailer::Base.deliveries.last
      end
    end

    private

    def oauth2_provider
      @oauth2_provider ||= begin
        provider = FactoryBot.create(:provider_account)

        provider.settings.update_column(:authentication_strategy, 'oauth2')

        provider
      end
    end

    def valid_user_data(email_verified: true, **attributes)
      ThreeScale::OAuth2::UserData.new(
        { kind: 'keycloak',
          uid: '12345',
          username: 'john',
          org_name: 'Alaska',
          email: 'john@example.net',
          email_verified: email_verified,
          authentication_id: nil }.merge(attributes)
      )
    end

    def mock_request
      request = mock('request')
      request.stubs(host: 'foo.bar', scheme: 'http', session: {})
      request
    end
  end

  private

  def mock_request
    request = mock('request')
    request.stubs(host: 'foo.bar', scheme: 'http', session: {})
    request
  end

  def mock_client(authentication_provider, uid:, username: 'username', email: 'mi@email.com', email_verified: true)
    client = mock('client')
    client.stubs(authenticate!: ThreeScale::OAuth2::UserData.new(
      uid: uid,
      kind: 'whatever',
      username: username,
      email: email,
      email_verified: email_verified,
      org_name: nil,
      authentication_id: uid
    ))

    ThreeScale::OAuth2::Client.expects(:build).with(authentication_provider).returns(client)
  end
end
