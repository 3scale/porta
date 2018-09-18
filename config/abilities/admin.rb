# here we define abilities for all admins no matter the account
Ability.define do |user|
  if user && user.admin?
    #COPY these come from accounts.rb

    # Users
    if user.account.provider? || (user.account.buyer? && user.account.provider_account.settings.try!(:useraccountarea_enabled?))
      can [:update, :destroy, :cancel], Account, :id => user.account.id # own user
      can :manage, User, :account_id => user.account_id # all users
    end

    # Admin can't delete himself/herself.
    # Admin can't change his/her role.
    cannot [:destroy, :update_role], User, :id => user.id

    can %i[destroy reject approve toggle_monthly_charging], Account, provider_account_id: user.account.id
    can(:update, Account) { |account| account.provider_account_id == user.account_id && !account.scheduled_for_deletion? }

    # abilities for buyer users
    can [:read, :create, :update, :update_role, :destroy, :suspend, :unsuspend], User, :account => {:provider_account_id => user.account.id}

    # Can't update role of a buyer user, if he/she is the only admin of his/her account.
    cannot :update_role, User do |buyer_user|
      buyer_user.account.provider_account_id == user.account.id &&
          buyer_user.admin? &&
          buyer_user.account.admins.count <= 1
    end

    #COPY these come from forum.rb

    can :manage, Topic do |topic|
      forum = topic.forum || topic.category.try!(:forum)
      forum.account == user.account
    end

    can :manage, Post do |post|
      can?(:manage, post.topic)
    end

  end
end
