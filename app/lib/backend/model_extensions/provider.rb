module Backend
  module ModelExtensions
    module Provider
      extend ActiveSupport::Concern

      included do
        after_commit :update_backend_default_service_id, if: -> { provider? && saved_change_to_default_service_id? }, unless: :master?
      end

      def update_backend_default_service_id
        return if destroyed?
        services.default.update_backend_service
      end
    end
  end
end


