# frozen_string_literal: true

class AccountDecorator < ApplicationDecorator
  def admin_user_display_name
    admin_user.decorate.display_name
  end

  private

  def admin_user
    @admin_user ||= (super || User.new)
  end
end
