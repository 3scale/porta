# frozen_string_literal: true

class Api::ApplicationPlansController < Api::PlansBaseController
  activate_menu :serviceadmin, :applications, :application_plans
  sublayout 'api/service'

  helper_method :plans_index_data
  delegate :plans_index_data, to: :presenter

  alias application_plans plans

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
    super(service, :default_application_plan)
  end

  protected

  def plan_type
    :application_plan
  end

  def scope
    service || current_account
  end

  def collection
    @collection ||= scope.application_plans.includes(:issuer)
  end

  def presenter
    @presenter ||= Api::ApplicationPlansPresenter.new(service: service, params: params, user: current_user)
  end
end
