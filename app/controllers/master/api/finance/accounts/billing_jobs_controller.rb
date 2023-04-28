# frozen_string_literal: true

class Master::Api::Finance::Accounts::BillingJobsController < Master::Api::Finance::BillingJobsController

  before_action :find_account

  # Trigger Billing by Account
  # POST /master/api/providers/{provider_id}/accounts/{account_id}/billing_jobs.xml
  def create
    Finance::BillingService.async_call(provider, billing_date, buyers_scope)
    head :accepted
  end

  private

  def find_account
    @account = provider.buyers.find(billing_params.require(:account_id))
  end

  def buyers_scope
    provider.buyers.where(id: @account.id)
  end
end
