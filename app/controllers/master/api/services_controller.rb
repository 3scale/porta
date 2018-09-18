class Master::Api::ServicesController < Master::Api::BaseController

  before_action :deny_on_premises_for_master

  def destroy
    before_contract_ids = service.contract_ids
    before_application_plan_ids = service.application_plan_ids

    service.destroy

    contracts = Contract.where(id: before_contract_ids)
    application_plans = ApplicationPlan.where(id: before_application_plan_ids)
    debug = {}
    if contracts.count + application_plans.count != 0
      debug = { before: { contracts: before_contract_ids, application_plans: before_application_plan_ids},
                after: { contracts: contracts.pluck(:id), application_plans: application_plans.pluck(:id)}
             }
    end

    data = {  service_id: service.id,
              provider_id: provider.id,
              errors: service.errors,
              debug: debug
           }


    Rails.logger.warn("--> Destroy service:\n #{data}")
    render json: data
  end

  private

  def service
    @service ||= provider.accessible_services.find(params[:id])
  end

  def provider
    @provider ||= Account.providers.find(params[:provider_id])
  end
end
