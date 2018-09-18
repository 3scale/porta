module Backend
  module ModelExtensions
    module Provider
      extend ActiveSupport::Concern

      included do
        after_commit :update_backend_default_service_id, :if => :provider?, :unless => :master?
      end

      def update_backend_default_service_id
        return if destroyed?
        return unless previously_changed?(:default_service_id)
        services.default.update_backend_service
      end
    end
  end
end


