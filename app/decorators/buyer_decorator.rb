# frozen_string_literal: true

class BuyerDecorator < AccountDecorator
  self.include_root_in_json = false

  def new_application_data
    {
      id: id.to_s,
      name: name,
      description: "Admin: #{admin_user_display_name}",
      createdAt: created_at.to_s(:long),
      contractedProducts: contracts,
      createApplicationPath: h.admin_buyers_account_applications_url(object),
      # TODO: multipleAppsAllowed: ? so that it is disabled if false
      # canSelectPlan: true # TODO needed?
    }
  end

  private

  def contracts
    bought_service_contracts.map do |contract|
      hash = contract.service.as_json(only: %i[id name], root: false)
      hash.merge!({ withPlan: contract.plan.as_json(only: %i[id name], root: false) })
    end
  end
end
