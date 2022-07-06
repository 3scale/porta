# frozen_string_literal: true

class Api::ServicePlansController < Api::PlansBaseController
  before_action :authorize_service_plans!

  activate_menu :serviceadmin, :subscriptions, :service_plans
  sublayout 'api/service'

  helper_method :default_plan_select_data, :plans_table_data
  delegate :default_plan_select_data, :plans_table_data, to: :presenter

  alias service_plans plans

  # rubocop:disable Lint/UselessMethodDefinition We need these, otherwise integration tests will fail
  def create
    super
  end

  def update
    super
  end

  def destroy
    super
  end
  # rubocop:enable Lint/UselessMethodDefinition

  def masterize
    super(@service, :default_service_plan)
  end

  protected

  def plan_type
    :service_plan
  end

  def collection(service_id = params[:service_id].presence)
    # start of our scope is current_account
    scope = current_account
    # if we have :service_id, then lookup service first
    scope = scope.accessible_services.find(service_id) if service_id
    # then return all service plans of current scope
    scope.service_plans
  end

  def authorize_service_plans!
    authorize! :manage, :service_plans
  end

  def presenter
    @presenter ||= Api::ServicePlansPresenter.new(service: @service, collection: collection, params: params)
  end
end
