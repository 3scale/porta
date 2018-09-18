# frozen_string_literal: true

class AuthenticationProviderPublishValidator < ApplicationValidator

  attr_reader :authentication_provider, :account

  def initialize(account, authentication_provider)
    @account = account
    @authentication_provider = authentication_provider
  end

  validate :validate_sso_enforced_and_only_one_published_authentication_provider, if: :authentication_provider_published?

  validate :validate_authentication_provider_tested, unless: :authentication_provider_published?
  validate :validate_authentication_provider_tested_after_last_update, unless: :authentication_provider_published?
  validate :validate_authentication_provider_tested_recently, unless: :authentication_provider_published?

  def authentication_provider_fully_tested?
    authentication_provider_tested? && authentication_provider_tested_recently? && authentication_provider_tested_after_last_update?
  end

  def authentication_provider_tested_at
    @authentication_provider_tested_at ||= authentication_provider.sso_authorizations.maximum(:updated_at)
  end

  def tested_state
    if !authentication_provider_tested?
      :untested
    elsif !authentication_provider_tested_after_last_update?
      :outdated
    elsif !authentication_provider_tested_recently?
      :expired
    else
      :tested
    end
  end

  def error_message
    errors.full_messages.first
  end

  def set_errors_in_authentication_provider
    errors[:base].each do |error_message|
      authentication_provider.errors.add(:published, error_message)
    end
  end

  private

  def authentication_provider_tested?
    authentication_provider_tested_at.present?
  end

  def authentication_provider_tested_recently?
    authentication_provider_tested? && 1.hour.ago < authentication_provider_tested_at
  end

  def authentication_provider_tested_after_last_update?
    return false unless authentication_provider_tested?
    authentication_provider_tested_at > @authentication_provider.updated_at
  end

  def validate_authentication_provider_tested
    return if authentication_provider_tested?
    errors.add(:base, 'The SSO Integration needs to be tested before you can publish it')
  end

  def validate_authentication_provider_tested_recently
    return if authentication_provider_tested_recently?
    errors.add(:base, 'The SSO Integration needs to be tested less than 1 hour ago in order to publish it')
  end

  def validate_authentication_provider_tested_after_last_update
    return if authentication_provider_tested_after_last_update?
    errors.add(:base, 'The SSO Integration needs to be tested after it has been changed before you can publish it')
  end

  def validate_sso_enforced_and_only_one_published_authentication_provider
    authentication_providers = account.self_authentication_providers.published
    return unless account.settings.enforce_sso? && authentication_providers.size == 1
    errors.add(:base, 'There needs to be at least 1 published SSO Integration when SSO is being enforced')
  end

  def authentication_provider_published?
    @authentication_provider.published?
  end
end
