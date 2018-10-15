# frozen_string_literal: true

module ServiceDiscovery
  module ModelExtensions
    module Service
      extend ActiveSupport::Concern

      # TODO: Remove and fix the creation form so it does not depend on these fake attributes os service
      included do
        class_eval do
          attr_accessor :source
          attr_accessor :namespace
        end
      end

      def discovered?
        kubernetes_service_link.present?
      end

      def discovered_api_docs_service
        api_docs_services.discovered.first
      end
    end

    module ApiDocs
      module Service
        extend ActiveSupport::Concern

        included do
          class_eval do
            attr_readonly :discovered
            scope :discovered, -> { where(discovered: true) }
            validate :unique_discovered_by_service
          end
        end

        def unique_discovered_by_service
          return unless service_id && discovered
          existing_discovered_api_doc = service.discovered_api_docs_service
          return if existing_discovered_api_doc.blank?
          return if existing_discovered_api_doc.id == self.id
          errors.add(:discovered, :taken)
        end
      end
    end
  end
end
