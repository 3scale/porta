# frozen_string_literal: true

class Api::ApplicationsController < Api::BaseController
  before_action :find_service
  before_action :activate_submenu
  before_action :find_cinstance, only: %i[show edit]

  include ThreeScale::Search::Helpers
  include DisplayViewPortion
  helper DisplayViewPortion::Helper

  activate_menu :main_menu => :serviceadmin, sidebar: :applications
  sublayout 'api/service'

  def index
    # TODO: This code is REALLY bad but it is copied and pasted from Buyers::ApplicationsController#index because
    # doing it well requires time and we don't have time right now.
    # Editing this action may require touching the other one

    @states = Cinstance.allowed_states.collect(&:to_s).sort
    @search = ThreeScale::Search.new(params[:search] || params)
    service_application_plans = @service.application_plans
    @application_plans = service_application_plans.stock
    @stock_and_custom_application_plans = service_application_plans.size

    @search.service_id = @service.id

    if params[:application_plan_id]
      @plan = @service.application_plans.find params[:application_plan_id]
      @search.plan_id = @plan.id
    end

    if params[:account_id]
      @account = current_account.buyers.find params[:account_id]
      @search.account = @account
      activate_menu :buyers, :accounts
    end

    @cinstances = current_user.accessible_cinstances
                      .scope_search(@search).order_by(params[:sort], params[:direction])
                      .preload(:service, user_account: [:admin_user], plan: [:pricing_rules])
                      .paginate(pagination_params)
  end

  def show
    @utilization = @cinstance.backend_object.utilization(@cinstance.service.metrics)
  end

  def edit; end

  private

  def find_cinstance
    @cinstance = @service.cinstances.find(params[:id])
  end

end
