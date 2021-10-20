# frozen_string_literal: true

class BuyerPresenter < SimpleDelegator
  include System::UrlHelpers.system_url_helpers

  def new_application_data
    {
      id: id,
      name: name,
      admin: decorate.admin_user_display_name,
      createdAt: created_at.to_s(:long),
      contractedProducts: contracts,
      createApplicationPath: admin_buyers_account_applications_path(id),
      multipleAppsAllowed: multiple_applications_allowed?
    }
  end

  protected

  def contracts
    bought_service_contracts.map do |contract|
      service = contract.service
      {
        id: service.id,
        name: service.name,
        withPlan: contract.plan.as_json(only: %i[id name], root: false)
      }
    end
  end
end
