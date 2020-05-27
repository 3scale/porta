# frozen_string_literal: true

# here we define abilities for members of provider account
Ability.define do |user|
  next unless user

  account = user.account

  next unless user.member? && account.tenant?

  # if you update this block, update also provider_admin.rb :/
  if user.has_permission?('finance')
    can :admin, :finance

    if account.settings.finance.allowed?
      can %i[read update], Finance::BillingStrategy, account_id: account.id
      can :manage, Invoice, provider_account_id: account.id

      if account.billing_strategy.charging_enabled?
        can :manage, :charging
      end
    end
  end

  if user.has_permission?('partners')
    can :manage, :partners
    can :manage, :applications
    can :admin, :multiple_users
    can :admin, :multiple_applications

    can :create, Account
    can :update, Account if account.provider_can_use?(:service_permissions)

    can %i[read show edit update], Cinstance, user.accessible_cinstances.where_values_hash

    # abilities for buyer users
    can %i[read update update_role destroy suspend unsuspend], User, account: { provider_account_id: user.account_id }
  end

  if user.has_permission?('plans')
    can :manage, :plans
    can :admin, :account_plans
    can :admin, :service_plans
    can :admin, :service_contracts
  end

  if user.has_permission?('settings')
    can :manage, :settings
  end

  if user.has_permission?('monitoring')
    can :manage, :monitoring
    can :manage, :analytics
  end

  if user.has_permission?('portal')
    can :manage, :portal
  end

  if user.has_permission?('legal')
    can :manage, LegalTerm
  end

  can :manage, BackendApiConfig if account.provider_can_use?(:api_as_product)

  # Member cannot manage permissions, neither his own, nor other members'
  cannot :update_permissions, User
end
