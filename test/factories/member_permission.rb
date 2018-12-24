FactoryBot.define do
  factory(:member_permission) do
    admin_section AdminSection.permissions.sample
    association :user, factory: :member
  end
end
