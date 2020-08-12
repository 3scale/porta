# frozen_string_literal: true

class ServiceContractDecorator < ApplicationDecorator
  delegate :admin_user_display_name, to: :user_account, prefix: :account

  private

  def user_account
    @user_account ||= super.decorate
  end
end
