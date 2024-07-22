# frozen_string_literal: true

class EnforceSSOValidator < ApplicationValidator

  SSO_NOT_TESTED_ERROR = I18n.t('provider.admin.account.enforce_sso.error_test')

  attr_reader :account, :user, :user_session, :strict

  def initialize(user_session: nil, account: nil, **options)
    options ||= {}
    if user_session
      @account = user_session.account
      @user = user_session.user
      @user_session = user_session
      @strict = options.fetch(:strict, true)
    else
      @account = account
      @strict = false
    end
    super()
  end

  validate :authentication_providers_exist
  validate :auth_tested, if: -> { no_errors? && strict }
  validate :auth_recently_updated, if: -> { no_errors? && strict }
  validate :user_logged_in_by_password, if: -> { no_errors? && strict }

  def error_message
    errors.full_messages.to_sentence
  end

  private

  def no_errors?
    errors.blank?
  end

  def user_logged_in_by_password
    user_session.sso_login?.tap do |by_sso|
      errors.add(:base, I18n.t('provider.admin.account.enforce_sso.error_by_sso')) unless by_sso
    end
  end

  def authentication_providers_exist
    authentication_providers.present?.tap do |exist|
      errors.add(:base, I18n.t('provider.admin.account.enforce_sso.error_exist')) unless exist
    end
  end

  def auth_recently_updated
    auth_updated_at = authentication_providers.maximum(:updated_at)
    (auth_updated_at > auth_tested_at).tap do |need_test|
      errors.add(:base, SSO_NOT_TESTED_ERROR) if need_test
    end
  end

  def auth_tested
    (auth_tested_at.present? && 1.hour.ago < auth_tested_at).tap do |tested|
      errors.add(:base, SSO_NOT_TESTED_ERROR) unless tested
    end
  end

  def authentication_providers
    @authentication_providers ||= account.self_authentication_providers.published
  end

  def auth_tested_at
    @auth_tested_at ||= user.sso_authorizations.maximum(:updated_at)
  end
end
