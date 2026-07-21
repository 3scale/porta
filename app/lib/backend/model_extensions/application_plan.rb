# frozen_string_literal: true

module Backend
  module ModelExtensions
    module ApplicationPlan
      extend ActiveSupport::Concern

      included do
        after_commit :sync_backend_application_plan_name, if: :saved_change_to_name?, on: :update
      end

      private

      def sync_backend_application_plan_name
        BackendUpdateApplicationPlanJob.perform_async(id)
      end
    end
  end
end
