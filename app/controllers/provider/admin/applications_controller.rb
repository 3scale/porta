# frozen_string_literal: true

class Provider::Admin::ApplicationsController < FrontendController
  include ThreeScale::Search::Helpers
  include ApplicationsControllerMethods

  before_action :authorize_partners
  before_action :find_plans
  before_action :find_states, only: :index
  before_action :find_applications, only: :index
  before_action :find_buyer, only: :create
  before_action :authorize_multiple_applications, only: :create
  before_action :find_application_plan, only: :create
  before_action :find_service, only: :create
  before_action :find_service_plan, only: :create
  before_action :find_cinstance, except: %i[index new create]
  before_action :initialize_cinstance, only: :create

  activate_menu :audience, :applications, :listing

  layout 'provider'

  helper_method :presenter

  def index; end

  def show
    @service = @cinstance.service
    @utilization = @cinstance.backend_object.utilization(@service.metrics)
    activate_menu(:serviceadmin)
  end

  def new; end

  def create
    if @cinstance.save
      flash[:notice] = 'Application was successfully created.'
      redirect_to provider_admin_application_path(@cinstance)
    else
      @cinstance.extend(AccountForNewPlan)
      render action: :new
    end
  end

  def edit; end

  def update
    # TODO: this is not needed if this controller is used only by providers
    @cinstance.validate_human_edition!
    @cinstance.attributes = params[:cinstance]

    respond_to do |format|
      json = @cinstance.to_json(only: %i[id name], methods: %i[errors])
      if @cinstance.save
        format.html do
          flash[:notice] = 'Application was successfully updated.'
          redirect_to provider_admin_application_path(@cinstance)
        end
        format.json { render json: json, status: :ok }
      else
        format.html { render action: :edit }
        format.json { render json: json, status: :bad_request }
      end
    end
  end

  def accept
    change_state('accept','The application has been accepted.')
  end

  def reject
    # TODO: use change_state('reject','The application has been rejected. params[:reason])
    @cinstance.reject!(params[:reason])
    flash[:notice] = 'The application has been rejected.'
    redirect_to admin_buyers_account_url(@cinstance.buyer_account)
  end

  def suspend
    change_state('suspend','The application has been suspended.')
  end

  def resume
    change_state('resume','The application is live again!')
  end

  def change_plan
    # there is no need to query available_application_plans as we already have a validation
    new_plan = accessible_plans.stock.find(plan_id)
    @cinstance.provider_changes_plan!(new_plan)
    flash[:notice] = "Plan changed to '#{new_plan.name}'."
    redirect_to provider_admin_application_url(@cinstance)
  end

  def change_user_key
    with_password_confirmation! do
      @cinstance.change_user_key!
      redirect_to provider_admin_application_url(@cinstance), notice: 'The key was successfully changed'
    end
  end

  def destroy
    if @cinstance.destroy
      flash[:notice] = 'The application was successfully deleted.'
      redirect_to provider_admin_applications_path
    else
      flash[:notice] = 'Not possible to delete application'
      redirect_back(fallback_location: provider_admin_applications_path)
    end
  end

  protected

  def presenter
    @presenter ||= Provider::Admin::ApplicationsNewPresenter.new(provider: current_account,
                                                                 user: current_user,
                                                                 cinstance: @cinstance)
  end
end
