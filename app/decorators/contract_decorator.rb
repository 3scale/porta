# frozen_string_literal: true

class ContractDecorator < ApplicationDecorator
  delegate :admin_user_display_name, to: :account, prefix: :account

  def account
    @account ||= super.decorate
  end

  def new_application_data
    {
      id: service.id,
      name: service.name,
      withPlan: plan.as_json(only: %i[id name], root: false)
    }
  end
end
