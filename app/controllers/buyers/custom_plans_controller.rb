# frozen_string_literal: true

class Buyers::CustomPlansController < FrontendController
  before_action :find_contract

  private

  def find_contract
    # this is caused by the fact of using the same controller for all contracts
    # first a paranoid check to avoid editing a contract not of provider
    @contract = current_account.provided_contracts.find params[:contract_id]
  end
end
