# frozen_string_literal: true

class Buyers::ServiceContracts::Bulk::ChangePlansController < Buyers::ServiceContracts::Bulk::BaseController
  before_action :find_services, only: %i[new create]

  helper_method :services, :plans

  def new; end

  def create
    # TODO: really change plan
    return unless (plan = service.service_plans.find_by(id: plan_id_param))

    service_contracts.reject { |contract| contract.plan_id == plan.id }
                      .each do |contract|
                        @errors << contract unless contract.change_plan(plan)
                      end

    handle_errors
    super
  end

  private

  attr_reader :service

  def services
    @services ||= find_services
  end

  def find_services
    # probably should preload :service and :user_account
    services = service_contracts.map(&:service).uniq
    return render(:multiple_services) unless services.size == 1

    @service = services.first
  end

  def plans
    @plans ||= service.service_plans
  end
end
