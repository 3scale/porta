# frozen_string_literal: true

class Signup::SignupParams
  def initialize(user_attributes: {}, account_attributes: {}, plans: [], defaults: {}, validate_fields: true)
    @user_attributes = user_attributes
    @account_attributes = prepare_account_attributes(account_attributes)
    @plans = plans
    @defaults = defaults
    @validate_fields = validate_fields
  end
  attr_reader :plans, :defaults

  def build_user_with_attributes_for_account(account)
    user = account.users.new
    user.validate_fields! if @validate_fields
    user.unflattened_attributes = @user_attributes
    user.signup_type = @user_attributes[:signup_type]
    user
  end

  def build_account_with_attributes_for_provider_account(provider_account)
    account = provider_account.buyers.new
    account.validate_fields! if @validate_fields
    account.unflattened_attributes = @account_attributes
    vat_rate = @account_attributes[:vat_rate]
    account.vat_rate = vat_rate.to_f if vat_rate
    account
  end

  private

  def prepare_account_attributes(attributes)
    attributes ||= {}
    attributes.delete('name') if attributes['org_name'].present?
    attributes
  end
end
