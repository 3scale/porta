# frozen_string_literal: true

class AccountDecorator < ApplicationDecorator
  delegate :display_name, :email, to: :admin_user, prefix: true

  def first_admin
    # when admin_users is eager loaded, filter manually to save an extra query
    @first_admin ||= admin_users.loaded? ? admin_users.find { |user| !user.impersonation_admin? } : super
  end

  private

  def admin_user
    @admin_user ||= (super || User.new).decorate
  end
end
