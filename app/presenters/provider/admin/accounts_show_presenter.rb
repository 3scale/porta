# frozen_string_literal: true

class Provider::Admin::AccountsShowPresenter
  attr_reader :account, :user

  delegate :can?, to: :ability
  delegate :field_label, :field_value, :heroku?, :timezone, to: :account
  delegate :features, :name, :id, to: :plan, prefix: true

  def initialize(account, user)
    @account = account
    @user = user
  end

  def show_edit_account_link?
    can?(:update, account)
  end

  def show_cancellation_section?
    multitenant? && !ThreeScale.config.onpremises && can?(:destroy, account)
  end

  def show_plan_section?
    multitenant? && !ThreeScale.config.onpremises
  end

  def show_upgrade_section?
    can?(:upgrade, account)
  end

  def visible_extra_fields
    account.visible_defined_fields_for(user).select do |field|
      field_value(field.name).present?
    end
  end

  def plan
    @plan ||= account.bought_plan
  end

  def absent_visible_features
    plan.issuer.features.visible.select do |feature|
      !plan.feature_enabled?(feature.system_name)
    end
  end

  def redhat_customer_verification_enabled?
    ThreeScale.config.redhat_customer_portal.enabled && !ThreeScale.config.onpremises
  end

  def red_hat_verified?
    redhat_customer_verification_enabled? && red_hat_account_verified_by.presence
  end

  def red_hat_account_number
    account.field_value('red_hat_account_number')
  end

  def red_hat_account_verified_by
    account.field_value('red_hat_account_verified_by')
  end

  private

  def multitenant?
    ThreeScale.tenant_mode.multitenant?
  end

  def ability
    @ability ||= Ability.new(user)
  end
end
