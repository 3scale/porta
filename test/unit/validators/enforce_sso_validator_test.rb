require 'test_helper'

class EnforceSSOValidatorTest < ActiveSupport::TestCase

  def setup
    @account = FactoryBot.create(:simple_provider)
    @user = FactoryBot.create(:user, account: @account)
    @user_session = @user.user_sessions.create
  end

  def test_valid?
    service = EnforceSSOValidator.new(user_session: @user_session)
    refute service.valid?
    assert_match 'No published authentication providers', service.error_message

    auth_provider = FactoryBot.create(:self_authentication_provider, account: @account, kind: 'base', published: true)
    service = EnforceSSOValidator.new(user_session: @user_session)
    refute service.valid?
    assert_match 'Authentication flow has to be checked', service.error_message

    sso_authorization = @user.sso_authorizations.create(authentication_provider: auth_provider, uid: 'alaska')
    service = EnforceSSOValidator.new(user_session: @user_session)
    refute service.valid?
    assert_match 'You need to be logged in by SSO', service.error_message

    @user_session.update(sso_authorization_id: sso_authorization.id)
    service = EnforceSSOValidator.new(user_session: @user_session)
    assert service.valid?
    assert_empty service.error_message

    sso_authorization.update_column(:updated_at, 0.5.hour.ago)
    service = EnforceSSOValidator.new(user_session: @user_session)
    refute service.valid?
    assert_match 'Authentication flow has to be checked', service.error_message

    auth_provider.update_column(:updated_at, 1.hour.ago)
    service = EnforceSSOValidator.new(user_session: @user_session)
    assert service.valid?
    assert_empty service.error_message
  end

  test 'non-strict mode with user session' do
    validator = EnforceSSOValidator.new(user_session: @user_session, strict: false)
    assert_not validator.valid?
    assert_match 'No published authentication providers', validator.error_message

    FactoryBot.create(:self_authentication_provider, account: @account, kind: 'base', published: true)
    validator = EnforceSSOValidator.new(user_session: @user_session, strict: false)
    assert validator.valid?
    assert_empty validator.error_message
  end

  test 'validate only by account, with no user session' do
    validator = EnforceSSOValidator.new(account: @account)
    assert_not validator.valid?
    assert_match 'No published authentication providers', validator.error_message

    FactoryBot.create(:self_authentication_provider, account: @account, kind: 'base', published: true)
    validator = EnforceSSOValidator.new(account: @account)
    assert validator.valid?
  end
end
