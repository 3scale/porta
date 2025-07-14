# frozen_string_literal: true

class Provider::Admin::ApplicationsController < FrontendController
  include ThreeScale::Search::Helpers
  include ApplicationsControllerMethods

  before_action :authorize_partners
  before_action :find_plans
  before_action :find_states, only: :index
  before_action :find_buyer, only: :create
  before_action :authorize_multiple_applications, only: :create
  before_action :find_application_plan, only: :create
  before_action :find_service, only: :create
  before_action :find_service_plan, only: :create
  before_action :find_cinstance, except: %i[index new create]
  before_action :initialize_cinstance, only: :create
  before_action :disable_client_cache
  before_action :initialize_new_presenter, only: :new

  activate_menu :audience, :applications, :listing

  layout 'provider'

  def show
    @service = @cinstance.service
    @utilization = @cinstance.backend_object.utilization(@service.metrics)
  end

  def new; end

  def create
    if @cinstance.save
      redirect_to provider_admin_application_path(@cinstance), success: t('.success')
    else
      initialize_new_presenter
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
        format.html { redirect_to provider_admin_application_path(@cinstance), success: t('.success') }
        format.json { render json: json, status: :ok }
      else
        format.html { render action: :edit }
        format.json { render json: json, status: :bad_request }
      end
    end
  end

  def accept
    change_state('accept', t('.success'))
  end

  def reject
    # TODO: use change_state('reject','The application has been rejected. params[:reason])
    @cinstance.reject!(params[:reason])
    redirect_to admin_buyers_account_url(@cinstance.buyer_account), success: t('.success')
  end

  def suspend
    change_state('suspend', t('.success'))
  end

  def resume
    change_state('resume', t('.success'))
  end

  def change_plan
    # there is no need to query available_application_plans as we already have a validation
    new_plan = accessible_plans.stock.find(plan_id)
    @cinstance.provider_changes_plan!(new_plan)
    redirect_to provider_admin_application_url(@cinstance), success: t('.success', name: new_plan.name)
  end

  def change_user_key
    with_password_confirmation! do
      @cinstance.change_user_key!
      redirect_to provider_admin_application_url(@cinstance), success: t('.success')
    end
  end

  def destroy
    if @cinstance.destroy
      redirect_to provider_admin_applications_path, success: t('.success')
    else
      redirect_back_or_to provider_admin_applications_path, danger: t('.not_possible')
    end
  end

  protected

  def initialize_new_presenter
    @presenter = Provider::Admin::ApplicationsNewPresenter.new(provider: current_account,
                                                               user: current_user,
                                                               cinstance: @cinstance)
  end
end
