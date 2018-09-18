# frozen_string_literal: true

# Logic connected with service subscriptions and application creation.
#
module Logic
  module Contracting
    module Service
      extend ActiveSupport::Concern

      included do

        # Has to have default or published application plan
        # so this method should be called only in this scope
        scope :can_create_application_contract, lambda {
          query = joining { application_plans.outer }.uniq
          .where.has {
            default_application_plan_id.not_eq(nil) |
            ((application_plans.state.eq('published') & application_plans.id.not_eq(nil)))
          }

          System::Database.oracle? ? where(id: query.select(:id)) : query
        }
      end

      def can_create_service_contract?
        service_plans.default or service_plans.published.exists?
      end
    end

    module Provider
      def provider_builds_application_for(buyer, application_plan, application_attrs = {}, service_plan = nil)
        service_contracted = buyer.bought_service_contracts.map(&:service).include?(application_plan.service)

        service_contract = unless service_contracted
                             if  service_plan
                               buyer.bought_service_contracts.create(plan: service_plan)
                             else
                               raise ActiveRecord::RecordNotFound
                             end
                           end

        application = Cinstance.new(user_account: buyer)

        application.validate_contract_hierarchy!
        application.validate_human_edition!

        application.plan_id = application_plan.id
        application.attributes = application_attrs

        application
      end

      def find_or_create_service_contract(buyer, service, service_plan = nil)
        unless bought_service_contracts.services.include?(service)
          service_plan ||= service.service_plans.default

          # warning added June 25th, should be removed when all guards
          # against creating app without a service subscription are in place
          if service_plan.nil? && service.service_plans.first
            service_plan = service.service_plans.first
            Rails.logger.warn "Service #{service.id} has no default service plan. Falling back to the first plan."
          end

          if service_plan
            buyer.bought_service_contracts.create(plan: service_plan)
          else
            return false
          end
        end
      end
    end

    module Buyer
      def can_create_application?(service = nil)
        services = services_can_create_app_on.where(:buyers_manage_apps => true)

        if service
          services.include?(service)
        else
          services.exists?
        end
      end

      def cannot_create_application?(service = nil)
        cannot_create_application_reason unless can_create_application?(service)
      end

      def cannot_create_application_reason
        'you are not subscribed to any service with a published application plan'
      end

      def services_can_create_app_on
        subscribed_services = bought_service_contracts.services(:live)
        subscribed_services.can_create_application_contract
      end
    end


    module ServiceContract
      extend ActiveSupport::Concern

      included do
        validate :one_contract_per_service, :on => :create
      end

      protected

      def one_contract_per_service
        if account && has_subscribed?
          errors.add(:base, 'already subscribed to this service')
        end
      end

      private

      def has_subscribed?
        account.bought_service_contracts.services.include?(service)
      end
    end


    module ApplicationContract
      extend ActiveSupport::Concern

      included do
         validate :service_subscription_requirement, :on => :create, :if => :validate_contract_hierarchy?
      end

      def validate_contract_hierarchy!
        @validate_contract_hierarchy = true
      end

      def validate_contract_hierarchy?
        !!@validate_contract_hierarchy
      end

      protected

      def service_subscription_requirement
        unless has_service_subscription?
          errors.add :base, "must have an approved subscription to service #{plan.issuer.name} before creating an application"
        end
      end

      private

      def has_service_subscription?
        return unless account
        account.bought_service_contracts.services(:live).include?(plan.issuer)
      end
    end
  end
end
