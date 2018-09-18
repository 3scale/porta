module DeveloperPortal
  module ControllerMethods
    module PlanChangesMethods
      protected

      class PlanChangesStore

        attr_reader :session

        def initialize(session)
          @session = session
        end

        def present?
          value.present?
        end

        def plan_ids
          value.values.map(&:to_i)
        end

        def contract_ids
          value.keys.map(&:to_i)
        end

        def [](key)
          value[key.to_s]
        end

        def save(contract_id, plan_id)
          return if contract_id.blank? || plan_id.blank?

          session[:plan_changes] ||= {}

          session[:plan_changes][contract_id.to_s] = plan_id.to_i
        end

        def delete(contract_id)
          value.delete(contract_id.to_s)
        end

        private

        def value
          session[:plan_changes] || {}
        end
      end

      # no need to be afraid of this instance variable since this module
      # can be use only in a controller
      def plan_changes_store
        @plan_changes_store ||= PlanChangesStore.new(session)
      end

      def plan_changes?
        plan_changes_store.present?
      end

      def store_plan_change!(contract_id, plan_id)
        plan_changes_store.save(contract_id, plan_id)
      end

      def unstore_plan_change!(contract_id)
        plan_changes_store.delete(contract_id)
      end
    end
  end
end
