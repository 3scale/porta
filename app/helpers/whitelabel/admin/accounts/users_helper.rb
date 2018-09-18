module Whitelabel::Admin::Accounts::UsersHelper
  def roles_collection_for_form_helpers(user)
    #HACK: we are leaving out contributor of the roles form, there is some issue
    # with removing contributor. TODO check contributor can be removed
    roles = User::DEFAULT_ROLES
    roles.map do |role|
      text = role.to_s.capitalize
      text << ' (full access)' if role == :admin
      text << ' (access control by group)' if role == :member && can?(:create_contributors, current_user.account)
      # text << ' (can update/create content)'     if role == :contributor
      [text, role]
    end
  end
end
