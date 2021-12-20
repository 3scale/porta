# frozen_string_literal: true

class Buyers::Accounts::Bulk::BaseController < Buyers::BulkBaseController
  before_action :find_accounts

  protected

  def scope
    :partners
  end

  def find_accounts
    @accounts = collection.decorate
  end

  def collection
    current_account.buyers.where(id: selected_ids_param)
  end

  def errors_template
    'buyers/accounts/bulk/shared/errors'
  end
end
