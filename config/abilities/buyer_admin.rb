# here we define abilities for admins of buyer account
Ability.define do |user|
  if user && user.admin? && user.account.buyer?
    provider = user.account.provider_account
    buyer = user.account

    if provider.settings.multiple_users.visible?
      can :create, Invitation
      can :manage, Invitation do |invitation|
        invitation.account == buyer
      end
    end
  end
end
