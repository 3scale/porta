# frozen_string_literal: true

class Api::ApplicationsController < FrontendController
  include ThreeScale::Search::Helpers
  include ApplicationsControllerMethods

  before_action :authorize_partners
  before_action :find_plans
  before_action :find_service
  before_action :find_states, only: :index
  before_action :find_applications, only: :index
  before_action :find_buyer, only: :create
  before_action :authorize_multiple_applications, only: :create
  before_action :find_application_plan, only: :create
  before_action :find_service_plan, only: :create
  before_action :initialize_cinstance, only: :create

  activate_menu :serviceadmin, :applications, :listing

  sublayout 'api/service'

  helper_method :presenter

  def index; end

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

  protected

  def define_search_scope(opts = {})
    super opts.reverse_merge(service: @service.id)
  end

  def find_service
    @service = accessible_services.find params[:service_id]
  end

  def accessible_plans
    super.where(issuer: @service)
  end

  def accessible_not_bought_cinstances
    super.where(service: @service)
  end

  def presenter
    @presenter ||= Api::ApplicationsNewPresenter.new(provider: current_account,
                                                     service: @service,
                                                     user: current_user,
                                                     cinstance: @cinstance)
  end
end
