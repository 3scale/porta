# frozen_string_literal: true

class AccountDecorator < ApplicationDecorator
  delegate :display_name, :email, to: :admin_user, prefix: true

  def first_admin
    @first_admin ||= (first_admin_cached || super)
  end

  private

  def first_admin_cached
    @first_admin_cached ||= admins&.first
  end

  def admins
    return nil unless users.loaded?

    @admins ||= users.select do |user|
      user.role == :admin && user.username != ThreeScale.config.impersonation_admin['username']
    end
  end

  def admin_user
    @admin_user ||= (super || User.new).decorate
  end
end
