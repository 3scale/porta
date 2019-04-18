# here we define abilities for all users of provider account, for members use
# provider_member.rb
Ability.define do |user|
  if user && user.account.provider?
    account = user.account

    account.settings.switches.each do |switch, value|
      can :see, switch if value.allowed?
    end

    can :manage, user

    can(:manage, :policy_registry) if account.tenant? && account.provider_can_use?(:policy_registry)
    can(:manage, :policy_registry_ui) if account.tenant? && account.provider_can_use?(:policy_registry_ui)

    # Overriding `can :manage, user` and `can :manage, User, :id => user.id`
    cannot :update_permissions, User, &:admin?

    # Can't destroy or update role of himself.
    cannot [:destroy, :update_role], user

    # Services
    can [:read, :show, :edit, :update], Service, user.accessible_services.where_values_hash

    #
    # Events
    #
    if user.has_permission?(:finance)
      can [:show], BillingRelatedEvent
    end
    if user.has_permission?(:partners)
      can [:show], AccountRelatedEvent
      can [:show], ServiceRelatedEvent do |event|
        user.has_access_to_service?(event.try(:service) || event.service_id)
      end
    end
    if user.has_permission?(:monitoring)
      can [:show], AlertRelatedEvent
    end
    can [:show], Reports::CsvDataExportEvent do |event|
      user.admin? && event.recipient.try!(:id) == user.id
    end

    can :admin, :social_logins if account.settings.branding.visible?
    can :admin, :iam_tools if account.settings.iam_tools.visible?

    can :update, User, :id => user.id

    if user.account.master_on_premises?
      cannot :manage, :credit_card
      cannot :read, Invoice, :buyer_account_id => account.id
    else
      can :manage, :credit_card
      can :read, Invoice, :buyer_account_id => account.id
    end

    #
    # Forum permissions
    #
    can :read, Topic do |topic|
      topic.forum.public? or topic.forum.account == account
    end

    can :read, TopicCategory do |category|
      category.forum.public? or category.forum.account == account
    end

    can :reply, Topic do |topic|
      forum = topic.forum || topic.category.try!(:forum)
      forum.account == account
    end

    if account.provider_can_use?(:new_notification_system)
      can [:show, :edit, :update], NotificationPreferences, user_id: user.id
      can [:show, :update], NotificationPreferences, &:new_record?
    end

    if account.partner?
      cannot :manage, Invoice
      cannot :manage, :credit_card
      cannot :upgrade, Account

      unless account.partner.can_manage_users?
        cannot :manage, User
        cannot :manage, Invitation
      end
    end

    can :manage, :access_tokens do |_, owner|
      owner == user
    end

    can :manage, AccessToken, owner_id: user.id

    if can?(:manage, :partners) && can?(:manage, account)
      can :export, :data
    end
  end
end
