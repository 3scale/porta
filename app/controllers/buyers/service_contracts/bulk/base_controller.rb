# frozen_string_literal: true

class Buyers::ServiceContracts::Bulk::BaseController < Buyers::BulkBaseController
  before_action :find_service_contracts

  protected

  def scope
    :service_contracts
  end

  def find_service_contracts
    @service_contracts = collection.decorate
  end

  def collection
    current_account.provided_service_contracts.where(id: selected_ids_param)
  end

  def errors_template
    'buyers/applications/bulk/shared/errors.html'
  end
end
