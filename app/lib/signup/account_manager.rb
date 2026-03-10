# frozen_string_literal: true

module Signup
  class AccountManager
    def initialize(manager_account)
      @manager_account = manager_account
      @account = manager_account.buyers.new
      @user = @account.users.new
    end

    attr_reader :manager_account, :account, :user

    def create(signup_params, signup_result_class = ::Signup::Result)
      transaction do
        assign_attributes_for_account(signup_params)
        assign_attributes_for_user(signup_params)
        signup_result = build_signup_result(signup_result_class)
        yield(signup_result) if block_given?
        save_result_with_plans(signup_result, signup_params) if signup_result.valid?
        signup_result
      end
    end

    private

    delegate :transaction, to: :manager_account

    class_attribute :account_builder, default: proc {}

    # This method smells of :reek:TooManyStatements and :reek:DuplicateMethodCall
    def save_result_with_plans(result, params)
      plans = plans_with_defaults(result, params.plans)
      return if plans.errors.any?
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

    def persist!(*)
      raise NotImplementedError, 'persist! should be implemented in subclasses'
    end

    def build_signup_result(signup_result_class)
      signup_result_class.new(user: user, account: account)
    end

    def assign_attributes_for_account(signup_params)
      account.validate_fields! if signup_params.validate_fields
      account_attributes = signup_params.attributes[:account]
      account_attributes.delete('name') if account_attributes['org_name'].present?
      account.assign_attributes(account_attributes)
      account_builder.call(account)
    end

    def assign_attributes_for_user(signup_params)
      user.validate_fields! if signup_params.validate_fields
      user.assign_attributes(signup_params.attributes[:user])
      user.role = :admin
    end

    def create_contract_plans_for_account!(account, plans, defaults)
      plans.each do |plan|
        attrs = [defaults[plan.class]].compact
        plan.create_contract_with!(account, *attrs)
      end
    end

    def plans_with_defaults(signup_result, plans_array)
      Signup::PlansWithDefaults.new(manager_account, plans_array) do |error|
        signup_result.add_error(message: error, attribute: :plans)
      end
    end

    def publish_related_event(result)
      event = Accounts::AccountCreatedEvent.create(result.account, result.user)
      Rails.application.config.event_store.publish_event(event)
    end
  end
end
