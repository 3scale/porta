# frozen_string_literal: true

class AccountDecorator < ApplicationDecorator
  delegate :display_name, :email, to: :admin_user, prefix: true

  def first_admin
    # when users are eager loaded, filter manually to save an extra query
    @first_admin ||= users.loaded? ? users.find { |user| user.admin? && !user.impersonation_admin? } : super
  end

  private

  def admin_user
    @admin_user ||= (super || User.new).decorate
  end
end
