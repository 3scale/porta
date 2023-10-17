# frozen_string_literal: true

class Buyers::Applications::Bulk::ChangePlansController < Buyers::Applications::Bulk::BaseController

  before_action :find_services

  helper_method :plans

  def create
    # TODO: really change plan
    return unless (plan = service.application_plans.find_by(id: plan_id_param))

    applications.reject { |app| app.plan_id == plan.id }
                .each do |application|
                  @errors << application unless application.change_plan(plan)
                end

    handle_errors
    super
  end

  private

  attr_reader :service

  def find_services
    # probably should preload :service and :user_account
    services = applications.map(&:service).uniq
    return render(:multiple_services) unless services.size == 1

    @service = services.first
  end

  def plans
    @plans ||= service.application_plans.not_custom.alphabetically
  end
end
