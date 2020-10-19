# frozen_string_literal: true

class BackendApi
  module Search
    extend ActiveSupport::Concern

    included do
      include ThreeScale::Search::Scopes

      after_save :index_backend_api
      after_destroy :index_backend_api

      self.allowed_search_scopes = %i[query]

      scope :by_query, ->(query) do
        options = {ids_only: true, per_page: 1_000_000, star: true, ignore_scopes: true, with: { }}
        where(id: search(ThinkingSphinx::Query.escape(query), options))
      end

      private

      def index_backend_api
        SphinxIndexationWorker.perform_later(self)
      end
    end
  end
end
