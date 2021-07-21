# frozen_string_literal: true

class Buyers::ApplicationsController < FrontendController
  include ThreeScale::Search::Helpers
  include ApplicationsControllerMethods

  before_action :authorize_partners
  before_action :find_plans
  before_action :find_buyer
  before_action :find_states, only: :index
  before_action :find_applications, only: :index
  before_action :authorize_multiple_applications, only: :create
  before_action :find_application_plan, only: :create
  before_action :find_service, only: :create
  before_action :find_service_plan, only: :create
  before_action :initialize_cinstance, only: :create

  activate_menu :buyers, :accounts, :listing

  helper_method :presenter

  def index; end

  def new
    @cinstance = @account.bought_cinstances.build
    extend_cinstance_for_new_plan
  end

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
    super opts.reverse_merge(account: @account.id)
  end

  def presenter
    @presenter ||= Buyers::ApplicationsNewPresenter.new(provider: current_account,
                                                        buyer: @account,
                                                        user: current_user,
                                                        cinstance: @cinstance)
  end

end
