# frozen_string_literal: true

class Signup::AccountManager
  def initialize(manager_account)
    @manager_account = manager_account
  end

  attr_reader :manager_account

  def create(signup_params, signup_result_class = ::Signup::Result)
    transaction do
      signup_result = build_signup_result(signup_params, signup_result_class)
      yield(signup_result) if block_given?
      save_result_with_plans(signup_result, signup_params) if signup_result.valid?
      signup_result
    end
  end

  private

  delegate :transaction, to: :manager_account

  class_attribute :account_builder, default: proc {}


  def save_result_with_plans(result, params)
    plans = plans_with_defaults(result, params.plans)
    return if plans.errors?
    transaction do
      begin
        persist!(result, plans, params.defaults)
        publish_related_event(result)
      rescue ActiveRecord::RecordInvalid
        raise ActiveRecord::Rollback
      rescue StateMachines::InvalidTransition => exception
        result.add_error(attribute: 'state', message: exception.message)
        raise ActiveRecord::Rollback
      end
    end
  end

  def persist!(result, plans, defaults)
    raise NotImplementedError, 'persist! should be implemented in subclasses'
  end

  def build_signup_result(signup_params, signup_result_class)
    account = build_account(signup_params)
    signup_result_class.new(user: build_user(signup_params, account), account: account)
  end

  def build_user(signup_params, account)
    user             = signup_params.build_user_with_attributes_for_account(account)
    user.role        = :admin
    user
  end

  def build_account(signup_params)
    account = signup_params.build_account_with_attributes_for_provider_account(manager_account)
    account_builder.call(account)
    account
  end

  def create_contract_plans_for_account!(account, plans, defaults)
    plans.each do |plan|
      attrs = [defaults[plan.class]].compact
      plan.create_contract_with!(account, *attrs)
    end
  end

  def plans_with_defaults(signup_result, plans_array)
    PlansWithDefaults.new(manager_account, plans_array) do |error|
      signup_result.add_error(message: error, attribute: :plans)
    end
  end

  def publish_related_event(result)
    event = Accounts::AccountCreatedEvent.create(result.account, result.user)
    Rails.application.config.event_store.publish_event(event)
  end

  # It is like Hash but it has provider and encapsulates default plan finding and adding logic
  class PlansWithDefaults
    attr_reader :provider, :errors
    attr_accessor :error_proc

    def initialize(provider, plans = nil, &error_proc)
      @provider = provider
      @error_proc = error_proc
      @plans = Hash.new { |k,v| k[v] = [] }
      self.selected = plans if plans
    end

    def selected=(plans)
      self.plans.update plans.group_by(&:class) if plans.present?
      add_default_plans_unless_present!
    end

    delegate :[], to: :plans
    delegate :to_a, to: :values

    def validate
      account_plan = plans[AccountPlan].first
      service_plans = plans[ServicePlan].group_by(&:issuer)
      application_plans = plans[ApplicationPlan].group_by(&:issuer)

      @errors = []

      unless plans[AccountPlan].size == 1
        @errors << "#{AccountPlan.model_name.human} is required"
      end

      unless account_plan&.issuer == provider
        @errors << "Issuer of #{AccountPlan.model_name.human} must be #{provider.org_name}"
      end

      application_plans.keys.each do |issuer|
        @errors << "Couldn't find a Service Plan for #{issuer.name}. Please contact the API administrator to fix this." if service_plans[issuer].blank?
      end

      service_plans.values.each do |plans|
        @errors << "Can subscribe only one plan per service" if plans.size > 1
      end

      @errors.each &@error_proc if @error_proc

      @errors.presence
    end

    def errors?
      validate if @errors.nil?
      @errors.present?
    end

    def valid?
      !errors?
    end

    def application_plan
      plans[ApplicationPlan].first
    end

    def to_a
      plans[AccountPlan] + plans[ServicePlan] + plans[ApplicationPlan]
    end

    delegate :each, to: :to_a

    protected

    attr_reader :plans

    def contract_first_published_service_plan?
      !service_plans_enabled? && provider.provider_can_use?(:published_service_plan_signup)
    end

    def service_plans_enabled?
      provider.settings.service_plans_ui_visible?
    end

    def add_default_plans_unless_present!
      add_default_or_nil(provider, provider.account_plans, AccountPlan)

      provider.services.each do |service|
        # returns nil when there is no default plan and no plan given
        # that means that there is no service plan and cannot be application plan
        unless (has_service_plan = add_default_or_nil(service, service.service_plans, ServicePlan))
          Rails.logger.debug("Skipping application plan in signup, because there is no service plan")
          next unless contract_first_published_service_plan?
        end

        next unless add_default_or_nil(service, service.application_plans, ApplicationPlan)
        next unless contract_first_published_service_plan?

        if !has_service_plan && (first_service_plan = service.service_plans.published.first)
          plans[ServicePlan] << first_service_plan
        end
      end
    end

    # returns true if there is already plan of same type and issuer
    # or adds default plan to array and returns the array
    def add_default_or_nil(issuer, plans, type)
      return true if self.plans[type].any? {|plan| plan.issuer == issuer }

      if (default = plans.default_or_nil)
        self.plans[type] << default
      end
    end

  end
end
