# frozen_string_literal: true

# here we define abilities for admins of providers account
Ability.define do |user|
  next unless user

  account = user.account

  next unless user.admin? && account.tenant?

  can :manage, account

  # admins can actualy adjust visibility of the switch on the buyer side
  account.settings.switches.each do |name, switch|
    can :admin, name
  end

  can :manage, Invitation
  can :manage, User, :id => user.id

  can :manage, :permissions

  # Update Permissions of a provider user:
  # 1) nobody can change user permissions of a provider admin
  # (admin should have full access)
  # 2) Only admin users (not members) can update permissions - of users of the same provider account
  # (this is also implicitly enabled by
  # `can :manage, User, :account_id => user.account_id` in `admin.rb`)
  can :update_permissions, User do |u|
    (u.account == user.account) && !u.admin?
  end

  if account.settings.branding.allowed?
    can :manage, :logo
  end

  if ThreeScale.config.onpremises
    cannot :upgrade, account
  elsif account.has_bought_cinstance? && !account.has_best_plan?
    can :upgrade, account
  end

  # Can't destroy or update role of myself.
  cannot [:destroy, :update_role], User, :id => user.id

  if account.settings.finance.allowed?
    can :manage, :finance
    can %i[read update], Finance::BillingStrategy, account_id: account.id
    can :manage, Invoice, provider_account_id: account.id
    can :manage, :charging if account.billing_strategy&.charging_enabled?
  end

  if can? :admin, :service_plans
    can :manage, :service_contracts
  end

  can :admin, :web_hooks
  can :admin, :groups
  can :manage, :partners
  can :manage, :applications
  can :manage, :plans
  can :manage, :monitoring
  can :manage, :analytics
  can :manage, :portal
  can :manage, :settings

  can :create, Account

  #COPY these come from forum.rb
  can :manage, TopicCategory do |category|
    category.forum.account = account
  end

  can :index, Service
  can :create, Service if account.can_create_service?
  can :destroy, Service do |service|
    service.account_id == user.account_id && can?(:manage, :multiple_services) && !service.default_or_last?
  end

  can %i[index show edit update create destroy], BackendApi

  can :manage, BackendApiConfig

  # TODO: there should be user.accessible_cinstances.where_values_hash, but that query is impossible
  # we have to wait until we denormalize Cinstance and add provider_account_id there

  can [:read, :show, :edit, :update], Cinstance

  can :read, :account_plans
end
