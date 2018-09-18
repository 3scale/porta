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

    if ThreeScale.config.onpremises
      cannot :manage, :multiple_services
      cannot :manage, :service_plans
      cannot :manage, :provider_plans
      cannot %i[see read admin manage], :account_plans
      cannot %i[create manage], :plans
      can :admin, :plans
    else
      can :manage, :multiple_services
      can :manage, :provider_plans
      can :read, :account_plans
      can :manage, :plans
      can :manage, :service_contracts
    end
    can :manage, :partners
    can :manage, :applications
    can :manage, :charging
    can :manage, :finance unless user.account.master_on_premises?
    can :manage, :monitoring
    can :manage, :analytics
    can :manage, :forum
    can :manage, :settings
    can :manage, :groups
    can :manage, :authentication_providers
    can :manage, :web_hooks

    #COPY these come from forum.rb
    can :manage, TopicCategory do |category|
      category.forum.account = user.account
    end

    can :update, Service, :account_id => user.account_id
    can :create, Service
    can :manage, :multiple_users
    can :manage, User
    can :manage, Invitation
    can :manage, Invoice, provider_account_id: user.account_id unless user.account.master_on_premises?

    user.account.settings.switches.each do |name, _switch|
      can :admin, name
    end
  end
end
