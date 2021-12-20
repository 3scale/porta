# frozen_string_literal: true

class Buyers::ServiceContracts::Bulk::ChangePlansController < Buyers::ServiceContracts::Bulk::BaseController

  before_action :find_services

  def new
    @plans = @service.service_plans
  end

  def create
    # TODO: really change plan
    @plan = @service.service_plans.find_by(id: plan_id_param)
    return unless @plan

    @service_contracts.each do |contract|
      unless contract.change_plan(@plan)
        @errors << contract
      end
    end

    handle_errors
  end

  private

  def plan_id_param
    params.require(:change_plans).require(:plan_id)
  end

  def find_services
    # probably should preload :service and :user_account
    services = @service_contracts.map(&:service).uniq
    unless services.size == 1
      return render(:multiple_services)
    end
    @service = services.first
  end

end
