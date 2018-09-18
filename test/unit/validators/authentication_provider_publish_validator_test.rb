require 'test_helper'

class AuthenticationProviderPublishValidatorTest < ActiveSupport::TestCase

  def test_initialize
    assert AuthenticationProviderPublishValidator.new(mock('account'), mock('auth_provider'))
  end

  def test_published_valid?
    account = FactoryGirl.create(:simple_provider)
    auth_provider = FactoryGirl.create(:self_authentication_provider, account: account, kind: 'base', published: true)

    validator = AuthenticationProviderPublishValidator.new(account, auth_provider)
    validator.valid?
    assert_nil validator.error_message

    account.settings.update_attributes(enforce_sso: true)
    validator = AuthenticationProviderPublishValidator.new(account, auth_provider)
    validator.valid?
    assert_match 'There needs to be at least 1 published SSO Integration', validator.error_message
  end

  def test_unpublished_valid?
    account = FactoryGirl.create(:simple_provider)
    auth_provider = FactoryGirl.create(:self_authentication_provider, account: account, kind: 'base')

    validator = AuthenticationProviderPublishValidator.new(account, auth_provider)
    validator.valid?
    assert_match 'The SSO Integration needs to be tested before you can publish it', validator.error_message

    auth_provider.expects(:sso_authorizations).returns(sso_authorizations(5.hour.ago)).at_least_once
    validator = AuthenticationProviderPublishValidator.new(account, auth_provider)
    validator.valid?
    assert_match 'The SSO Integration needs to be tested after it has been changed before you can publish it', validator.error_message

    auth_provider.update_column(:updated_at, 5.hours.ago)
    auth_provider.expects(:sso_authorizations).returns(sso_authorizations(2.hour.ago)).at_least_once
    validator = AuthenticationProviderPublishValidator.new(account, auth_provider)
    validator.valid?
    assert_match 'The SSO Integration needs to be tested less than 1 hour ago in order to publish it', validator.error_message

    auth_provider.expects(:sso_authorizations).returns(sso_authorizations(0.5.hour.ago)).at_least_once
    validator = AuthenticationProviderPublishValidator.new(account, auth_provider)
    validator.valid?
    assert_nil validator.error_message
  end

  private

  def sso_authorizations(maximum)
    mock('sso_authorizations', maximum: maximum)
  end
end
