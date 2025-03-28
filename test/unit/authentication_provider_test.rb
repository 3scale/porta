require 'test_helper'

class AuthenticationProviderTest < ActiveSupport::TestCase

  test "name" do
    authentication_provider = FactoryBot.build_stubbed(:authentication_provider, name: '')
    assert_not authentication_provider.valid?
    assert authentication_provider.errors[:name].present?
  end

  test "system_name" do
    authentication_provider = FactoryBot.build(:authentication_provider, name: "foo", system_name: nil, account_id: 1)
    authentication_provider.save!
    assert_equal "foo", authentication_provider.system_name

    authentication_provider = FactoryBot.build(:authentication_provider, name: "foo", system_name: nil, account_id: 1)
    assert_not authentication_provider.valid?
    assert authentication_provider.errors[:system_name].present?

    authentication_provider = FactoryBot.build(:authentication_provider, name: "foo", system_name: nil, account_id: 2)
    assert authentication_provider.valid?, authentication_provider.errors.to_a.to_sentence
    assert_equal "foo", authentication_provider.system_name
  end

  test 'validate urls' do
    authentication_provider = FactoryBot.build_stubbed(:authentication_provider)

    authentication_provider.site = ''
    authentication_provider.token_url = ''
    authentication_provider.authorize_url = ''
    authentication_provider.user_info_url = ''

    assert authentication_provider.valid?

    authentication_provider.site = 'foo'
    authentication_provider.token_url = 'foo'
    authentication_provider.authorize_url = 'foo'
    authentication_provider.user_info_url = 'foo'

    assert_not authentication_provider.valid?

    errors = authentication_provider.errors

    assert_equal %i[authorize_url site token_url user_info_url], errors.map(&:attribute).sort
    assert_equal ['Invalid URL format'], errors.map(&:message).uniq

    authentication_provider.site = 'https://example.org'
    authentication_provider.token_url = 'http://example.org'
    authentication_provider.authorize_url = 'http://example.org'
    authentication_provider.user_info_url = 'https://example.org'

    assert authentication_provider.valid?
  end

  test 'blank site and whitespaces in URLs' do
    keycloak = FactoryBot.build_stubbed(:keycloak_authentication_provider)
    auth0 = FactoryBot.build_stubbed(:auth0_authentication_provider)
    [keycloak, auth0].each do |auth|
      auth.site = ''
      assert_not auth.valid?
      assert ["can't be blank"], auth.errors.messages_for(:site)

      auth.site = '  http://example.org  '
      assert_not auth.valid?
      assert ["can't contain whitespaces"], auth.errors.messages_for(:site)

      auth.site = 'abc'
      assert_not auth.valid?
      assert ["Invalid URL format"], auth.errors.messages_for(:site)

      auth.site = 'http://example.org'
      assert auth.valid?
    end
  end

  test 'callback_account' do
    account = FactoryBot.create(:simple_provider)
    auth_provider = FactoryBot.build_stubbed(:authentication_provider, account: account)
                              .becomes(AuthenticationProvider::GitHub)
    master = FactoryBot.build_stubbed(:master_account)

    auth_provider.branding_state = 'threescale_branded'
    assert auth_provider.threescale_branded?, 'should be 3scale branded'
    assert_equal master, auth_provider.callback_account

    auth_provider.branding_state = 'custom_branded'
    assert auth_provider.custom_branded?, 'should have custom branding'
    assert_equal auth_provider.account, auth_provider.callback_account
  end

  test 'find_kind' do
    assert_equal AuthenticationProvider::Keycloak, AuthenticationProvider.find_kind('keycloak')
    assert_equal AuthenticationProvider::Auth0, AuthenticationProvider.find_kind('auth0')
    assert_equal AuthenticationProvider::GitHub, AuthenticationProvider.find_kind('github')
  end

  test 'self.kind' do
    assert_equal 'github', AuthenticationProvider::GitHub.kind
    assert_equal 'auth0', AuthenticationProvider::Auth0.kind
    assert_equal 'keycloak', AuthenticationProvider::Keycloak.kind
  end

  test 'kind' do
    assert_equal 'github', AuthenticationProvider::GitHub.new.kind
    assert_equal 'auth0', AuthenticationProvider::Auth0.new.kind
    assert_equal 'keycloak', AuthenticationProvider::Keycloak.new.kind
  end

  test 'branded_available?' do
    config = { client_id: 'id', client_secret: 'secret' }
    ThreeScale::OAuth2.stubs(config: { authentication_provider: config })

    assert_not_predicate AuthenticationProvider, :branded_available?

    config[:enabled] = true
    assert_predicate AuthenticationProvider, :branded_available?

    config[:client_id] = ''
    config[:client_secret] = ''
    assert_not_predicate AuthenticationProvider, :branded_available?
  end

  test 'initial state github' do
    AuthenticationProvider.stubs(branded_available?: false)
    github = AuthenticationProvider::GitHub.new
    assert_equal github.branding_state, 'custom_branded'

    AuthenticationProvider.stubs(branded_available?: true)
    github = AuthenticationProvider::GitHub.new
    assert_equal github.branding_state, 'threescale_branded'
  end

  test 'ssl verification' do
    auth = AuthenticationProvider.new
    assert_not auth.skip_ssl_certificate_verification

    assert_equal OpenSSL::SSL::VERIFY_PEER, auth.ssl_verify_mode

    auth.skip_ssl_certificate_verification = true
    assert_equal OpenSSL::SSL::VERIFY_NONE, auth.ssl_verify_mode
  end

  test '::published' do
    ap_published = FactoryBot.create(:authentication_provider, published: true)
    FactoryBot.create(:authentication_provider, published: false)

    assert_equal [ap_published], AuthenticationProvider.published
    assert_equal 2, AuthenticationProvider.count
  end

  test '#published: github not branded on new record' do
    AuthenticationProvider::GitHub.stubs(:branded_available?).returns(false)
    auth = AuthenticationProvider::GitHub.new(published: true)
    assert auth.published
  end

  test '#published: github branded on new record' do
    AuthenticationProvider::GitHub.stubs(:branded_available?).returns(true)
    auth = AuthenticationProvider::GitHub.new(published: false)
    assert auth.published
  end

  test '#published: github not branded on existing record can publish it' do
    AuthenticationProvider::GitHub.stubs(:branded_available?).returns(false)
    auth = AuthenticationProvider::GitHub.create!(published: false, client_id: '12345', client_secret: '12345')
    assert_not auth.published
    auth.published = true
    auth.save!
    auth.reload
    assert auth.published
  end

  test '#published: github branded on existing record can unpublish it' do
    AuthenticationProvider::GitHub.stubs(:branded_available?).returns(true)
    auth = AuthenticationProvider::GitHub.create!(client_id: '12345', client_secret: '12345')
    assert auth.published
    auth.published = false
    auth.save!
    auth.reload
    assert_not auth.published
  end

  test "Red Hat customer system_name can't be used" do
    auth = AuthenticationProvider.new system_name: RedhatCustomerPortalSupport::RH_CUSTOMER_PORTAL_SYSTEM_NAME
    assert_not auth.valid?
    assert_includes auth.errors[:system_name], 'is reserved'
  end
end
