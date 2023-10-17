# frozen_string_literal: true

class Buyers::ServiceContracts::Bulk::BaseController < Buyers::BulkBaseController
  before_action :service_contracts, only: :create

  helper_method :service_contracts

  def create
    notify_success
  end

  protected

  def scope
    :service_contracts
  end

  def service_contracts
    @service_contracts ||= collection.decorate
  end

  def collection
    @collection ||= current_account.provided_service_contracts.where(id: selected_ids_param)
  end

  def errors_template
    'buyers/service_contracts/bulk/shared/errors.html'
  end
end
