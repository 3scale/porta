# frozen_string_literal: true

class Master::Api::Finance::BillingJobsController < Master::Api::Finance::BaseController

  include Finance::ControllerRequirements
  include Finance::BillingDates::ControllerMethods

  before_action :verify_write_permission, only: [:create]
  before_action { finance_module_required(provider) }

  # Trigger Billing
  # POST /master/api/providers/{provider_id}/billing_jobs.xml
  def create
    Finance::BillingService.async_call(provider, billing_date)
    head :accepted
  end

  private

  def provider
    @provider ||= Account.providers.find(billing_params[:provider_id])
  end

  def billing_params
    @billing_params ||= params.permit(%i[provider_id account_id date])
  end
end
