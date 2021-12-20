# frozen_string_literal: true

class Buyers::Applications::Bulk::ChangePlansController < Buyers::Applications::Bulk::BaseController

  before_action :find_services

  def new
    @plans = @service.application_plans.not_custom.alphabetically
  end

  def create
    # TODO: really change plan
    @plan = @service.application_plans.find_by(id: plan_id_param)
    return unless @plan

    @applications.each do |application|
      unless application.change_plan(@plan)
        @errors << application
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
    services = @applications.map(&:service).uniq
    unless services.size == 1
      return render(:multiple_services)
    end
    @service = services.first
  end
end
