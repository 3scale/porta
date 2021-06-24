# frozen_string_literal: true

class Buyers::ApplicationsController < FrontendController
  include ThreeScale::Search::Helpers
  include ApplicationsControllerMethods

  before_action :authorize_partners
  before_action :find_plans
  before_action :find_buyer
  before_action :authorize_multiple_applications, only: :create
  before_action :find_application_plan, only: :create
  before_action :find_service, only: :create
  before_action :find_service_plan, only: :create

  helper_method :accessible_services

  activate_menu :buyers, :accounts, :listing

  def new
    @cinstance = @account.bought_cinstances.build
    extend_cinstance_for_new_plan
  end

  # Create is handled by each individual controller so that it don't render a different 'new' template in case of an error
  def create
    super

    if @cinstance.save
      flash[:notice] = 'Application was successfully created.'
      redirect_to provider_admin_application_path(@cinstance)
    else
      @cinstance.extend(AccountForNewPlan)
      render action: :new
    end
  end

  protected

  def define_search_scope
    super({ account: @account.id })
  end

end
