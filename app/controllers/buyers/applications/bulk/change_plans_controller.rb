class Buyers::Applications::Bulk::ChangePlansController < Buyers::Applications::Bulk::BaseController

  before_action :find_services

  def new
    @plans = @service.application_plans.not_custom.alphabetically
  end

  def create
    # TODO: really change plan
    @plan = @service.application_plans.find_by_id params[:change_plans][:plan_id]
    return unless @plan

    @errors = []
    @applications.each do |application|
      unless application.change_plan(@plan)
        @errors << application
      end
    end

    handle_errors
  end

  private

  def find_services
    # probably should preload :service and :user_account
    services = @applications.map(&:service).uniq
    unless services.size == 1
      return render(:multiple_services)
    end
    @service = services.first
  end
end
