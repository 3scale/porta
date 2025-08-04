# here we define abilities for all users without caring about his role
Ability.define do |user|
  if user
    # Anyone can read their own account.
    can(:read, Account) { |account| user.account == account }

    # redundant with one above?
    can :read, Account, :account => {:id => user.account.id}
  end
end
