# frozen_string_literal: true

class AccountDecorator < ApplicationDecorator
  delegate :display_name, :email, to: :admin_user, prefix: true

  private

  def admin_user
    @admin_user ||= (super || User.new).decorate
  end
end
