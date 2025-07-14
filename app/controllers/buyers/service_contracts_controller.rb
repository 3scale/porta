# frozen_string_literal: true

class Buyers::ServiceContractsController < Buyers::BaseController
  before_action :authorize_service_contracts

  before_action :deny_on_premises_for_master
  before_action :find_account, except: [:index]
  before_action :find_service, only: %i[new create]
  before_action :find_service_contract, only: %i[edit update approve change_plan destroy]

  include ThreeScale::Search::Helpers

  activate_menu :buyers, :accounts, :subscriptions

  helper_method :presenter

  attr_reader :presenter

  def index
    @presenter = Buyers::ServiceContractsIndexPresenter.new(user: current_user,
                                                            params: params,
                                                            provider: current_account)

    activate_menu(*presenter.menu_context)
    @service = presenter.service # For vertical nav...
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
      flash[:success] = t('.success') # Page will be reloaded
    else
      flash.now[:danger] = t('.error')
    end

    respond_to(:js)
  end

  def edit
    @service_plans = @service_contract.issuer.service_plans # TODO: .where.not(id: @service_contract.plan)

    render layout: false # Rendered inside a modal
  end

  def update
    service = @service_contract.issuer
    new_plan = service.service_plans.find(service_contract_plan_id)

    if @service_contract.change_plan!(new_plan)
      flash.now[:success] = t('.success')
    else
      flash.now[:danger] = t('.error')
    end

    respond_to(:js)
  end

  def destroy
    service_subscription = ServiceSubscriptionService.new(@account)
    service_contract = service_subscription.unsubscribe(@service_contract)

    if service_contract.destroyed?
      flash[:success] = t('.success')
    else
      flash[:danger] = t('.error')
    end

    redirect_back_or_to(admin_buyers_account_service_contracts_path(@account))
  end

  def approve
    if resource.accept
      flash[:success] = t('.success')
    else
      flash[:danger] = t('.error')
    end

    redirect_back_or_to(admin_buyers_account_service_contracts_path(@account))
  end

  private

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
