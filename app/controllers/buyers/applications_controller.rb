# frozen_string_literal: true

class Buyers::ApplicationsController < FrontendController
  include ThreeScale::Search::Helpers
  include ApplicationsControllerMethods

  before_action :authorize_partners
  before_action :find_plans
  before_action :find_buyer
  before_action :find_states, only: :index # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :authorize_multiple_applications, only: :create
  before_action :find_application_plan, only: :create
  before_action :find_service, only: :create
  before_action :find_service_plan, only: :create
  before_action :initialize_cinstance, only: :create
  before_action :initialize_new_presenter, only: :new

  activate_menu :buyers, :accounts, :listing

  def new
    @cinstance = @account.bought_cinstances.build
    extend_cinstance_for_new_plan
  end

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

  def initialize_new_presenter
    @presenter = Buyers::ApplicationsNewPresenter.new(provider: current_account,
                                                      buyer: @account,
                                                      user: current_user,
                                                      cinstance: @cinstance)
  end
end
