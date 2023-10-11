# frozen_string_literal: true

class Buyers::ServiceContractsController < Buyers::BaseController
  before_action :authorize_service_contracts

  before_action :deny_on_premises_for_master
  before_action :find_account, except: [:index]
  before_action :find_service, only: %i[new create]
  before_action :find_service_contract, only: %i[edit update approve change_plan destroy]

  include ThreeScale::Search::Helpers

  activate_menu :buyers, :accounts, :subscriptions

  def index
    @states = ServiceContract.allowed_states.collect(&:to_s).sort
    @services = accessible_services.includes(:service_plans)
    @search = ThreeScale::Search.new(params[:search] || params)
    @plans = current_account.service_plans
    @multiservice = current_account.multiservice?

    if (service_id = params[:service_id] || @search.service_id)
      @service = @services.find service_id
      @search.service_id = @service.id
    end

    if (service_plan_id = params[:service_plan_id] || @search.service_plan_id)
      @plan = current_account.service_plans.find(service_plan_id)
      @search.plan_id = @plan.id
      @service ||= @plan.service
    end

    if params[:account_id]
      @account = current_account.buyers.find params[:account_id]
      @search.account = @account.id
      activate_menu :audience, :accounts, :listing
    end

    @service_contracts = current_user.accessible_service_contracts
              .scope_search(@search).order_by(*sorting_params)
              .includes(plan: %i[pricing_rules], user_account: [:admin_user])
              .paginate(pagination_params)
              .decorate

    activate_menu :serviceadmin, :subscriptions if @service
  end

  def new
    @service_plans = @service.service_plans
    @service_contract = collection.build :plan => @service_plans.default_or_nil

    render layout: false # Rendered inside a modal
  end

  def create
    # FIXME: model should validate that subscribed plan has same issuer account as buyer account
    @service_contract = @account.bought_service_contracts.create(service_contract_params)

    if @service_contract.persisted?
      flash[:success] = "Service contract created successfully"
    else
      @service_plans = @service.service_plans
      @form = render_to_string :action => :new, :layout => false, :format => :html
    end

    respond_to(:js)
  end

  def edit
    @service_plans = @service_contract.issuer.service_plans

    render layout: false # Rendered inside a modal
  end

  def update
    service = @service_contract.issuer
    new_plan = service.service_plans.find(service_contract_plan_id)

    if @service_contract.change_plan!(new_plan)
      flash[:success] = "Plan of the contract was changed."
    end

    respond_to(:js)
  end

  def destroy
    service_subscription = ServiceSubscriptionService.new(@account)
    service_contract = service_subscription.unsubscribe(@service_contract)

    if service_contract.destroyed?
      flash[:notice] = t('service_contracts.unsubscribe_confirmation')
    else
      flash[:error] = t('service_contracts.unsubscribe_failure')
    end

    redirect_back(fallback_location: admin_buyers_account_service_contracts_path(@account))
  end

  def approve
    if resource.accept
      flash[:notice] = 'Service contract was approved.'
    else
      flash[:error] = 'Cannot approve service contract.'
    end

    redirect_back(fallback_location: admin_buyers_account_service_contracts_path(@account))
  end

  private

  def sorting_params
    column = params[:sort] || 'cinstances.id'
    direction =  params[:direction] || 'DESC'
    [ column, direction ]
  end

  def collection
    @account.bought_service_contracts.permitted_for(current_user)
  end

  def service_contract_params
    params.permit(service_contract: [:plan_id])
          .fetch(:service_contract).merge(plan: service_plan)
  end

  def find_service_contract
    @service_contract = collection.find params[:id]
  end

  def find_account
    @account = current_account.buyers.find params[:account_id]
  end

  def find_service
    @service = service
  end

  def authorize_service_contracts
    authorize! :manage, :service_contracts
  end

  def service
    @service ||= accessible_services.find(params[:service_id])
  end

  def service_plan(plan_id = service_contract_plan_id)
    @service_plan ||= service.service_plans.find_by(id: plan_id)
  end

  def service_contract_plan_id
    params[:service_contract][:plan_id]
  end

  def accessible_services
    (current_user || current_account).accessible_services
  end
end
