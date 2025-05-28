# frozen_string_literal: true

class Api::ApplicationsController < FrontendController
  include ThreeScale::Search::Helpers
  include ApplicationsControllerMethods

  before_action :authorize_partners
  before_action :find_service
  before_action :find_plans
  before_action :find_states, only: :index # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :find_buyer, only: :create
  before_action :authorize_multiple_applications, only: :create
  before_action :find_application_plan, only: :create
  before_action :find_service_plan, only: :create
  before_action :initialize_cinstance, only: :create
  before_action :initialize_new_presenter, only: :new

  activate_menu :serviceadmin, :applications, :listing

  sublayout 'api/service'

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

  protected

  def define_search_scope(opts = {})
    super opts.reverse_merge(service: @service.id)
  end

  def find_service
    @service = accessible_services.find params[:service_id]
  end

  def find_plans
    @application_plans = accessible_plans.where(issuer: @service)
  end

  def initialize_new_presenter
    @presenter = Api::ApplicationsNewPresenter.new(provider: current_account,
                                                   service: @service,
                                                   user: current_user,
                                                   cinstance: @cinstance)
  end
end
