class DeveloperPortal::Admin::ServiceContractsController < DeveloperPortal::BaseController

  before_action :authorize

  before_action :find_provider
  before_action :find_service, :find_plan, :find_plans

  activate_menu :dashboard

  liquify prefix: 'services'

  def new
    if @plans.size == 1
      #  HACK: hackish - but if we'd redirect, the plan (which can be
      #  default and hidden) would have to be published so we just call
      #  it directly => GET changes state :/
      params[:service_contract] = { :plan_id => @plans.first.id }
      create
    else
      @service_contract = ServiceContract.new(params[:service_contract])
    end

    assign_drops subscription: Liquid::Drops::ServiceContract.new(@service_contract, @service)
  end

  def create
    @service_contract = current_account.bought_service_contracts.build params[:service_contract]
    @service_contract.plan = site_account.service_plans.find params[:service_contract][:plan_id]

    if @service_contract.save
      flash[:notice] = "You have successfully subscribed to a service."
      redirect_to admin_buyer_services_path
    else
      render :new
    end
  end

  private

  def find_provider
    @provider = current_account.provider_account
  end

  def authorize
    authorize! :manage, :service_contracts
  end

  def find_plans
    @plans = if @plan
               [ @plan ]
             elsif @service
               @service.service_plans.published
             else
               @provider.service_plans.published
             end

    # try to pick the default plan if nothing is published
    if @plans.empty?
      if @plans.respond_to?(:default) && @plans.default
        @plans = [ @plans.default ]
      else
        render :plain => 'No plan to subscribe to', :status => 404
      end
    end
  end

  # Warning: the param name 'service_id' should match with what
  # Liquid::Filters::ParamFilter generates
  #
  def find_service
    if params[:service_id].present?
      @service = @provider.services.find_by_id(params[:service_id])
    end
  end

  # Warning: the param name 'plan_id' should match with what
  # Liquid::Filters::ParamFilter generates
  #
  def find_plan
    if params[:plan_ids].present?
      @plan = @provider.service_plans.published.find(params[:plan_ids].first)
    end
  end

end
