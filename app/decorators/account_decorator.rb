# frozen_string_literal: true

class AccountDecorator < ApplicationDecorator
  delegate :display_name, :email, to: :admin_user, prefix: true

  self.include_root_in_json = false

  def new_application_data
    {
      id: id.to_s,
      name: name,
      description: "Admin: #{admin_user_display_name}",
      createdAt: created_at.to_s(:long),
      contractedProducts: contracts,
      createApplicationPath: h.admin_buyers_account_applications_path(object),
      multipleAppsAllowed: multiple_applications_allowed?
    }
  end

  private

  def admin_user
    @admin_user ||= (super || User.new).decorate
  end

  def contracts
    bought_service_contracts.decorate.map(&:new_application_data)
  end
end
