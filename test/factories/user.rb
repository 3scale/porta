FactoryBot.define do
  factory(:pending_user, :class => :user) do
    sequence(:email) { |n| "foo#{n}@example.net" }
    sequence(:username) { |n| "dude#{n}" }
    password { 'superSecret1234#' }
    signup_type { 'new_signup' } # means the user signed up for a plan
  end

  factory(:active_user, :parent => :pending_user) do
    after(:create) do |user|
      user.activate!
    end
  end

# This is currently just an alias for :pending_user, and is used for tests where the state
# is not important/relevant.
#
# TODO: Perhaps it should rather be an alias for :active_user, as that is the de-facto default
# state?
  factory(:user, :parent => :pending_user)

  factory(:admin, :parent => :user) do
    role { :admin }
  end

  factory(:active_admin, :parent => :admin) do
    after(:create) do |user|
      user.activate!
    end
  end

  factory(:user_with_account, :parent => :user) do
    association :account, :factory => :account_without_users
  end

  factory(:member, :parent => :user) do
    role { :member }
  end
end
