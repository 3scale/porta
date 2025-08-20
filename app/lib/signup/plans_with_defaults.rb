# frozen_string_literal: true

module Signup
  class PlansWithDefaults
    attr_reader :provider

    def initialize(provider, plans = nil, &error_proc)
      @provider = provider
      @error_proc = error_proc
      @plans = Hash.new { |hash, key| hash[key] = [] }
      self.selected = plans if plans
    end

    def selected=(plans)
      self.plans.update plans.group_by(&:class) if plans.present?
      add_default(provider, provider.account_plans, AccountPlan)
      provider.services.each { |service| add_default_plans_to_service(service) }
    end

    delegate :[], to: :plans

    def errors
      @errors ||= begin
        errors = []

        errors += account_plan_errors
        errors += application_plan_errors
        errors += service_plan_errors

        errors.each(&error_proc)

        errors
      end
    end

    def to_a
      account_plans + service_plans + application_plans
    end

    def application_plans
      @application_plans ||= plans[ApplicationPlan]
    end

    delegate :each, to: :to_a

    protected

    attr_reader :plans

    private

    attr_reader :error_proc

    def account_plans
      @account_plans ||= plans[AccountPlan]
    end

    def service_plans
      @service_plans ||= plans[ServicePlan]
    end

    def contract_first_published_service_plan?
      !service_plans_enabled? && provider.provider_can_use?(:published_service_plan_signup)
    end

    def service_plans_enabled?
      provider.settings.service_plans_ui_visible?
    end

    def add_default_plans_to_service(service)
      # returns nil when there is no default plan and no plan given
      # that means that there is no service plan and cannot be application plan
      unless (has_service_plan = add_default(service, service.service_plans, ServicePlan))
        Rails.logger.debug("Skipping application plan in signup, because there is no service plan")
        return unless contract_first_published_service_plan?
      end

      return unless add_default(service, service.application_plans, ApplicationPlan)
      return unless contract_first_published_service_plan?

      return if has_service_plan || !(first_service_plan = service.service_plans.published.first)
      service_plans << first_service_plan
    end

    # returns true if there is already plan of same type and issuer
    # or adds default plan to array and returns the array
    def add_default(issuer, plans, type)
      return true if any_plan_for?(issuer: issuer, plan_type: type)

      default = plans.default_or_nil
      self.plans[type] << default if default
    end

    def account_plan_errors
      account_plan = account_plans.first
      human_model_name = AccountPlan.model_name.human
      return ["#{human_model_name} is required"] unless account_plan
      account_plan.issuer == provider ? [] : ["Issuer of #{human_model_name} must be #{provider.org_name}"]
    end

    def application_plan_errors
      application_plans.group_by(&:issuer).keys.each_with_object([]) do |issuer, errors|
        next if any_plan_for?(issuer: issuer, plan_type: ServicePlan)
        errors << "Couldn't find a Service Plan for #{issuer.name}. Please contact the API administrator to fix this."
      end
    end

    def service_plan_errors
      service_plans.group_by(&:issuer).values.each_with_object([]) do |plans, errors|
        errors << "Can subscribe only one plan per service" if plans.size > 1
      end
    end

    def any_plan_for?(issuer:, plan_type:)
      ActiveRecord::Associations::Preloader.new(records: Array(plans[plan_type]), associations: [:issuer]).call
      plans[plan_type].any? { |plan| plan.issuer == issuer }
    end
  end
end
