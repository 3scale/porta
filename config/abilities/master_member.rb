Ability.define do |user|

  if user && user.member? && user.account.master?

    if user.has_permission?(:finance) && !user.account.master_on_premises?

      can :admin, :finance

      if user.account.settings.finance.allowed?
        can [:read, :update], Finance::BillingStrategy, account_id: user.account.id
        can :manage, Invoice, provider_account_id: user.account.id

        if user.account.billing_strategy.charging_enabled?
          can :manage, :charging
        end
      end
    end

    can(:create, Account, &:signup_provider_possible?)

    if user.has_permission?(:partners)
      can :manage, :partners
      can :manage, :provider_plans
      if user.account.provider_can_use?(:service_permissions)
        can :resume, Account
        can(:update, Account) { |account| !account.scheduled_for_deletion? }
      end
    end

  end
end
