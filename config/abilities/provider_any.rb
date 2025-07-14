# frozen_string_literal: true

# here we define abilities for all users of provider account, for members use provider_member.rb
Ability.define do |user| # rubocop:disable Metrics/BlockLength
  if user&.account&.provider?
    account = user.account

    account.settings.switches.each do |switch, value|
      can :see, switch if value.allowed?
    end

    can :manage, user

    can :manage, :policy_registry if account.tenant? && account.provider_can_use?(:policy_registry) && user.has_permission?(:policy_registry)

    # Overriding `can :manage, user` and `can :manage, User, :id => user.id`
    cannot :update_permissions, User, &:admin?

    # Can't destroy or update role of himself.
    cannot %i[destroy update_role], user

    # Services
    user_accessible_services = user.accessible_services
    can %i[show edit update], Service, user_accessible_services.where_values_hash unless user_accessible_services.is_a? ActiveRecord::NullRelation

    #
    # Events
    #
    can [:show], BillingRelatedEvent if user.has_permission?(:finance)

    if user.has_permission?(:partners)
      can [:show], AccountRelatedEvent do |event|
        next true if user.has_access_to_all_services?

        service_ids = event.try(:service_ids) || [event.try(:service)&.id || event.try(:service_id)].compact

        service_ids.any? { user.has_access_to_service?(_1) }
      end

      can [:show], ServiceRelatedEvent do |event|
        user.has_access_to_service?(event.try(:service) || event.try(:service_id))
      end
    end

    if user.has_permission?(:monitoring)
      can [:show], AlertRelatedEvent do |event|
        user.has_access_to_service?(event.try(:service) || event.try(:service_id))
      end
    end

    can [:show], Reports::CsvDataExportEvent do |event|
      user.admin? && event.recipient&.id == user.id
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
      forum = topic.forum || topic.category&.forum
      forum.account == account
    end

    can %i[show edit update], NotificationPreferences, user_id: user.id
    can %i[show update], NotificationPreferences, &:new_record?

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

    can :export, :data if can?(:manage, :partners) && can?(:manage, account)
  end
end
