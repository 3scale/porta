Factory.define(:member_permission) do |factory|
  factory.admin_section AdminSection.permissions.sample
  factory.association :user, factory: :member
end
