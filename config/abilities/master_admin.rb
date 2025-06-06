# here we define abilities for admins of master account
#
Ability.define do |user|
  if user && user.admin? && user.account.master?
    can [:read, :show, :edit, :update, :create, :destroy], Cinstance

    can :manage, :logo

    can %i[read delete configure], Account
    can(:update, Account) { |account| !account.scheduled_for_deletion? }

    can(:impersonate, Account) { |account| account.has_impersonation_admin? && !account.scheduled_for_deletion? }

    can :suspend, Account do | account |
      account.can_suspend?
    end

    can :resume, Account do | account |
      account.can_resume?
    end

    can :manage, user.account
    can(:create, Account, &:signup_provider_possible?)

    can :manage, :plans
    can :manage, Service

    if ThreeScale.config.onpremises
      cannot :manage, :multiple_services
      cannot :manage, :service_plans
      cannot :manage, :provider_plans
      cannot %i[see read admin manage], :account_plans
      cannot :create, :plans
      cannot %i[create destroy], Service
    else
      can :manage, :multiple_services
      can :manage, :provider_plans
      can :read, :account_plans
      can :manage, :service_contracts
    end
    can :manage, :partners
    can :manage, :applications
    can :manage, :charging
    can :manage, :finance unless user.account.master_on_premises?
    can :manage, :monitoring
    can :manage, :analytics
    can :manage, :settings
    can :manage, :groups
    can :manage, :authentication_providers
    can :manage, :web_hooks

    can %i[index show edit update create destroy], BackendApi

    can :manage, BackendApiConfig

    can :manage, :multiple_users
    can :manage, User
    can :manage, Invitation
    can :manage, Invoice, provider_account_id: user.account_id unless user.account.master_on_premises?

    can :manage, :permissions

    user.account.settings.switches.each do |name, _switch|
      can :admin, name
    end
  end
end
