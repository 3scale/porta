# here we define abilities for members of provider account
Ability.define do |user|

  if user && user.member? && user.account.provider? && !user.account.master?
    # if you update this block, update also provider_admin.rb :/
    if user.has_permission?("finance")
      can :admin, :finance

      if user.account.settings.finance.allowed?
        can [ :read, :update ], Finance::BillingStrategy, :account_id => user.account.id
        can :manage, Invoice, :provider_account_id => user.account.id

        if user.account.billing_strategy.charging_enabled?
          can :manage, :charging
        end
      end
    end

    if user.has_permission?("partners")
      can :manage, :partners
      can :manage, :applications
      can :admin, :multiple_users
      can :admin, :multiple_applications

      can :create, Account
      can :update, Account if user.account.provider_can_use?(:service_permissions)

      can [:read, :show, :edit, :update], Cinstance, user.accessible_cinstances.where_values_hash

      # abilities for buyer users
      can [:read, :update, :update_role, :destroy, :suspend, :unsuspend], User, account: { provider_account_id: user.account_id }
    end

    if user.has_permission?("plans")
      can :manage, :plans
      can :admin, :account_plans
      can :admin, :service_plans
      can :admin, :service_contracts
    end

    if user.has_permission?("settings")
      can :manage, :settings
    end

    if user.has_permission?("monitoring")
      can :manage, :monitoring
      can :manage, :analytics
    end

    if user.has_permission?("portal")
      can :manage, :portal
    end

    if user.has_permission?("legal")
      can :manage, LegalTerm
    end
  end
end
