# frozen_string_literal: true

module Backend
  module ModelExtensions
    module ApplicationPlan
      extend ActiveSupport::Concern

      included do
        after_commit :sync_backend_application_plan_name, if: :saved_change_to_name?, on: :update
      end

      def update_backend_plan
        backend_id = service.backend_id
        cinstances.includes(:service, :plan).find_in_batches do |batch|
          ThreeScale::Core::Application.save_batch(backend_id, batch.map(&:backend_application_attributes))
        end
      end

      private

      def sync_backend_application_plan_name
        BackendUpdateApplicationPlanWorker.perform_later(id)
      end
    end
  end
end
