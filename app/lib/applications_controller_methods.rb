# frozen_string_literal: true

module ApplicationsControllerMethods
  def self.included(base)
    base.class_eval do
      helper_method :accessible_services, :presenter
      attr_reader :presenter
    end
  end

  def index
    @presenter = ApplicationsIndexPresenter.new(application_plans: @application_plans,
                                                accessible_services: accessible_services,
                                                service: @service,
                                                provider: current_account,
                                                accessible_plans: accessible_plans,
                                                buyer: @account,
                                                user: current_user,
                                                params: params)
  end

  protected

  # TODO: this should be done by buy! method
  def initialize_cinstance
    @cinstance = current_account.provider_builds_application_for(@account, @application_plan, params[:cinstance], @service_plan)
    @cinstance.validate_human_edition!
  end

  def change_state(action, message, *rest)
    @cinstance.public_send("#{action}!", *rest)

    respond_to do |format|
      format.html do
        redirect_to provider_admin_application_url(@cinstance), success: message
      end

      format.js do
        flash.now[:success] = message
        render action: 'update_state'
      end
    end
  end

  def find_states
    @states = Cinstance.allowed_states.collect(&:to_s).sort
  end

  def find_cinstance
    @cinstance = accessible_not_bought_cinstances.includes(plan: %i[service pricing_rules])
                                                 .find(params[:id])
  end

  def find_buyer
    @account = current_account.buyers.find params[:account_id]
  end

  def find_plans
    @application_plans = accessible_plans.stock
  end

  def find_service
    @service = @application_plan.service
  end

  def find_provider
    @provider = current_account
  end

  def find_application_plan
    find_plans # FIXME: @application_plans is empty in #create even if find_plans is called before_action
    @application_plan = @application_plans.find plan_id
  end

  def find_service_plan
    service_plans = @service.service_plans
    @service_plan = if (service_plan_id = params[:cinstance].delete(:service_plan_id))
                      service_plans.find(service_plan_id)
                    else
                      @service.default_service_plan || service_plans.first
                    end
  end

  def plan_id
    @plan_id ||= params.require(:cinstance).permit(:plan_id).tap { |plan_params| plan_params.require(:plan_id) }[:plan_id]
  end

  def accessible_services
    @accessible_services ||= current_user.accessible_services.includes(:application_plans)
  end

  def accessible_not_bought_cinstances
    current_user.accessible_cinstances.not_bought_by(current_account)
  end

  def accessible_plans
    current_account.application_plans.where(issuer: accessible_services)
  end

  def authorize_partners
    authorize! :manage, :partners
  end

  def authorize_multiple_applications
    authorize! :manage, :multiple_applications if @account.has_bought_cinstance?
  end

  module AccountForNewPlan
    # dummy methods for formstastic
    def service_plan_id; end
  end

  def extend_cinstance_for_new_plan
    @cinstance.extend(AccountForNewPlan)
  end
end
