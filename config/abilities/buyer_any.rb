# here we define abilities for users of buyer account
Ability.define do |user|
  if user && user.account.buyer?
    account = user.account
    provider = account.provider_account

    can :manage_alerts, Cinstance do |cinstance|
      cinstance.buyer_alerts_enabled?
    end

    switches = provider.settings.switches

    # account plans switch have special treatment
    if switches.delete(:account_plans).visible?
      if provider.account_plans.published.length > 1
        can :see, :account_plans
      end
    end

    # buyers can see feature, when their provider has it visible
    switches.each { |name, switch| can(:see, name) if switch.visible? }


    if provider.settings.try! :useraccountarea_enabled?
      can [:update], User, :id => user.id # this is not granted anywhere else to non admin buyers, dont remove
    else # this is a bit absurd but it seems that if the setting is disabled, all such abilities need to removed
      cannot [:update], User, :id => user.id # this is here to remove the abilities from the admins which is granted separately
      cannot [:update, :destroy, :cancel], Account, :id => account.id
    end

    if provider.settings.finance.visible?
      can :admin, :finance

      can :read, Invoice, :buyer_account_id => account.id
      can :manage, :credit_card
    end

    if provider.settings.multiple_applications_visible?
      can :manage, :applications
    end

    new_app_condition = lambda do
      (provider.settings.multiple_applications_visible? ||
          !provider.settings.multiple_applications_visible? &&
              account.bought_cinstances.count.zero?)
    end

    can(:create_application, Service) do |service|
      service.buyers_manage_apps? && new_app_condition.call
    end

    can(:create, Cinstance) do |ci|
      ci.plan.service.buyers_manage_apps? && new_app_condition.call
    end

    can([:update, :destroy], Cinstance) { |ci| ci.service.buyers_manage_apps? }

    #TODO: keys are now a separated model, move this auth to that object
    can(:manage_keys, Cinstance)         { |c| c.service.buyers_manage_apps? && c.service.buyers_manage_keys? }
    can(:regenerate_user_key, Cinstance) { |c| c.service.buyers_manage_apps? && c.service.buyer_key_regenerate_enabled? }

    if can?(:see, :multiple_services)
      can :manage, :service_contracts
    end


    can([ :update ], ServiceContract, :user_account_id => account.id)


    #
    # Forum permissions
    #

    can :read, Topic do |topic|
     topic.forum.public? or topic.forum.account == provider
    end

    can :read, TopicCategory do |category|
      category.forum.public? or category.forum.account == provider
    end

    can :reply, Topic do |topic|
      forum = topic.forum || topic.category.try!(:forum)
      forum.account == provider
    end

  end
end
