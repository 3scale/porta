# frozen_string_literal: true

class Buyers::Accounts::Bulk::BaseController < Buyers::BulkBaseController
  before_action :accounts, only: :create

  helper_method :accounts

  def create
    notify_success
  end

  protected

  def scope
    :partners
  end

  def accounts
    @accounts ||= collection.decorate
  end

  def collection
    @collection ||= current_account.buyers.where(id: selected_ids_param)
  end

  def errors_template
    'buyers/accounts/bulk/shared/errors'
  end
end
