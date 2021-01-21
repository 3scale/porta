# frozen_string_literal: true

#FIXME: why is this controller not inheriting from Buyers::Base ?????
class Buyers::ApplicationsController < FrontendController

  include ThreeScale::Search::Helpers
  include DisplayViewPortion
  helper DisplayViewPortion::Helper

  before_action :authorize_partners
  before_action :find_buyer, :only => [:create]
  before_action :authorize_multiple_applications, :only => [:create]

  before_action :find_cinstance, :except => [:index, :create, :new]
  before_action :find_provider,  only: %i[new create update]

  activate_menu :buyers

  layout 'provider'

  def index
    # TODO: Editing this action may require editing Api::ApplicationsController

    activate_menu :audience, :applications, :listing

    @states = Cinstance.allowed_states.collect(&:to_s).sort
    @search = ThreeScale::Search.new(params[:search] || params)
    @application_plans = accessible_plans

    if params[:service_id]
      @service = accessible_services.find params[:service_id]
      @search.service_id = @service.id
    end

    if params[:application_plan_id]
      @plan = @application_plans.find params[:application_plan_id]
      @search.plan_id = @plan.id
      @service ||= @plan.service
    end

    if params[:account_id]
      @account = current_account.buyers.find params[:account_id]
      @search.account = @account.id
      activate_menu :buyers, :accounts, :listing
    end

    @cinstances = accessible_not_bought_cinstances
      .scope_search(@search).order_by(params[:sort], params[:direction])
      .preload(:service, user_account: [:admin_user], plan: [:pricing_rules])
      .paginate(pagination_params)
      .decorate

    display_view_portion!(:service) if current_account.multiservice?
  end

  def new
    # binding.pry
    if params[:account_id]
      # We're in buyers/accounts/:id/applications/new
      find_buyer
      @plans = accessible_plans.stock
      @cinstance = @buyer.bought_cinstances.build
      extend_cinstance_for_new_plan
      @account = current_account.buyers.find params[:account_id]
      activate_menu :buyers, :accounts
    else
      # We're in buyers/applications/new
    end
  end

  # TODO: this should be done by buy! method
  def create
    @plans = accessible_plans.stock
    application_plan = @plans.find plan_id
    service_plan = if service_plan_id = params[:cinstance].delete(:service_plan_id)
                     application_plan.service.service_plans.find(service_plan_id)
                   end

    @cinstance = current_account.provider_builds_application_for(@buyer, application_plan, params[:cinstance], service_plan)
    @cinstance.validate_human_edition!

    if @cinstance.save
      flash[:notice] = 'Application was successfully created.'
      redirect_to(admin_service_application_path(@cinstance.service, @cinstance))
    else
      @cinstance.extend(AccountForNewPlan)
      render :action => :new
    end
  end

  def update
    # TODO: this is not needed if this controller is used only by providers
    @cinstance.validate_human_edition!
    @cinstance.attributes = params[:cinstance]

    respond_to do |format|
      if @cinstance.save
        format.html do
          flash[:notice] = 'Application was successfully updated.'
          redirect_to(admin_service_application_path(@cinstance.service, @cinstance))
        end
        format.json { render :json => @cinstance.to_json(:only => [:id, :name], :methods => [:errors]), :status => :ok }
      else
        format.html { render :action => :edit }
        format.json { render :json => @cinstance.to_json(:only => [:id, :name], :methods => [:errors]), :status => :bad_request }
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
    service = @cinstance.service
    new_plan = accessible_plans.stock.find(plan_id)
    @cinstance.provider_changes_plan!(new_plan)
    flash[:notice] = "Plan changed to '#{new_plan.name}'."
    redirect_to admin_service_application_url(service, @cinstance)
  end

  def change_user_key
    with_password_confirmation! do
      @cinstance.change_user_key!
      redirect_to admin_service_application_url(@cinstance.service, @cinstance), notice: 'The key was successfully changed'
    end
  end

  def destroy
    if @cinstance.destroy
      flash[:notice] = 'The application was successfully deleted.'
      redirect_to admin_buyers_applications_path
    else
      flash[:notice] = 'Not possible to delete application'
      redirect_to :back
    end
  end

  private

  def change_state(*args)
    action, message = args.shift, args.shift
    @cinstance.send("#{action}!", *args)

    respond_to do |format|
      format.html do
        flash[:notice] = message
        redirect_to admin_service_application_url(@cinstance.service, @cinstance)
      end

      format.js do
        flash.now[:notice] = message
        render :action => 'update_state'
      end
    end
  end

  def accessible_not_bought_cinstances
    current_user.accessible_cinstances.not_bought_by(current_account)
  end

  def find_cinstance
    @cinstance = accessible_not_bought_cinstances
                  .includes(plan: [:service, :original, :plan_metrics, :pricing_rules])
                  .find(params[:id])
    @account = @cinstance.account
  end

  def find_buyer
    @buyer = current_account.buyers.find(params[:account_id])
  end

  def find_service(id = params[:service_id])
    @service = accessible_not_bought_cinstances.find(id) if id
  end

  def find_provider
    @provider = current_account
  end

  def accessible_services
    @accessible_services ||= current_user.accessible_services.includes(:application_plans)
  end

  helper_method :accessible_services

  def accessible_plans
    current_account.application_plans.where(issuer: accessible_services)
  end

  def plan_id
    @plan_id ||= params.require(:cinstance).permit(:plan_id).tap { |plan_params| plan_params.require(:plan_id) }[:plan_id]
  end

  def authorize_partners
    authorize! :manage, :partners
  end

  def authorize_multiple_applications
    authorize! :manage, :multiple_applications if @buyer.has_bought_cinstance?
  end

  module AccountForNewPlan
    # dummy methods for formstastic
    def service_plan_id; end
  end

  def extend_cinstance_for_new_plan
    @cinstance.extend(AccountForNewPlan)
  end

end
