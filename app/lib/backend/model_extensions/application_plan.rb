# frozen_string_literal: true

module Backend
  module ModelExtensions
    module ApplicationPlan
      extend ActiveSupport::Concern

      included do
        after_commit :sync_backend_application_plan_name, if: :saved_change_to_name?, on: :update
      end

      def update_backend_plan
        cinstances.find_in_batches do |batch|
          applications = batch.map do |app|
            state = app.state
            state = :active if app.live?

            {
              :service_id => service.backend_id,
              :id         => app.application_id,
              :state      => state,
              :plan_id    => id,
              :plan_name  => name,
              :redirect_url => app.redirect_url
            }
          end

          ThreeScale::Core::Application.save_batch(service.backend_id, applications)
        end
      end

      private

      def sync_backend_application_plan_name
        BackendUpdateApplicationPlanWorker.perform_later(id)
      end
    end
  end
end
