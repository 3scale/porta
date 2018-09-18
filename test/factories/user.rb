Factory.define(:pending_user, :class => :user) do |factory|
  factory.sequence(:email) { |n| "foo#{n}@example.net" }
  factory.sequence(:username) { |n| "dude#{n}" }
  factory.password 'supersecret'
  factory.signup_type 'new_signup' # means the user signed up for a plan
end

Factory.define(:active_user, :parent => :pending_user) do |factory|
  factory.after_create do |user|
    user.activate!
  end
end

# This is currently just an alias for :pending_user, and is used for tests where the state
# is not important/relevant.
#
# TODO: Perhaps it should rather be an alias for :active_user, as that is the de-facto default
# state?
Factory.define(:user, :parent => :pending_user) do |user|
end

Factory.define(:admin, :parent => :user) do |user|
  user.role :admin
end

Factory.define(:active_admin, :parent => :admin) do |factory|
  factory.after_create do |user|
    user.activate!
  end
end

Factory.define(:user_with_account, :parent => :user) do |user|
  user.association :account, :factory => :account_without_users
end

Factory.define(:member, :parent => :user) do |user|
  user.role :member
end
