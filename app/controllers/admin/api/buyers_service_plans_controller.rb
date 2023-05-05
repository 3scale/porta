class Admin::Api::BuyersServicePlansController < Admin::Api::BuyersBaseController
  representer ServicePlan

  ## FIXME: QUESTION: this two probably should go, for the same reason the list of bought applications plans

  # Returns the service plans bought by a partner
  # GET /admin/api/accounts/{account_id}/service_plans.xml
  def index
    respond_with(bought_service_plans)
  end

  # Makes a partner buy a service plan (deprecated).
  # POST /admin/api/accounts/{account_id}/service_plans/{id}/buy.xml
  def buy
    contract = buyer.buy(service_plan)

    respond_with(contract, serialize: service_plan)
  end

  protected

  def bought_service_plans
    @bought_service_plans ||= buyer.bought_service_plans
  end

  def service_plan
    @service_plan ||= current_account.service_plans.stock.find(params[:id])
  end

end
