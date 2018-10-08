# frozen_string_literal: true

class Api::EndUserPlansController < Api::PlansBaseController
  before_action :authorize_end_users!

  before_action :activate_sidebar_menu

  # before_action :find_plan, :only => [:edit, :update, :destroy, :masterize]
  # before_action :find_plans, :only => [:index]

  before_action :find_service, only: %i[index new edit create update destroy masterize]

  sublayout 'api/service'

  def index
    @new_plan = EndUserPlan
  end

  def new
    @plan = collection.build params[:end_user_plan]
  end

  def edit; end

  def create
    @plan = collection.build params[:end_user_plan]

    if @plan.save
      @plan.reload
      redirect_to plans_index_path
    else
      render :new
    end
  end

  def update
    super params[:end_user_plan]
  end

  def destroy
    super
  end

  def masterize
    masterize_plan do
      @service.default_end_user_plan = @plan
      @service.save!
    end
  end

  protected

  def find_service
    # TODO: write other find_service methods like below so it would crash with proper error of invalid params
    service_id = @plan.try!(:service_id) || params.require(:service_id)
    @service   = current_user.accessible_services.find(service_id)

    authorize! :update, @service
  end

  def authorize_end_users!
    authorize! :manage, :end_users
  end

  def activate_sidebar_menu
    activate_menu :sidebar => :end_user_plans
  end

  def collection(service_id = params[:service_id].presence)
    # start of our scope is current_account
    scope = current_account
    # if we have :service_id, then lookup service first
    scope = scope.accessible_services.find(service_id) if service_id
    # then return all service plans of curren scope
    scope.end_user_plans
  end
end
