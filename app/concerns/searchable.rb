# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    include ThreeScale::Search::Scopes

    after_commit :index_object

    self.allowed_search_scopes = %i[query]

    scope :by_query, ->(query) do
      options = { ids_only: true, star: true, ignore_scopes: true, with: { },
                  per_page: ThreeScale::Search::Helpers::MAX_SEARCH_PAGE_SIZE }
      where(id: unscoped.search(ThinkingSphinx::Query.escape(query), options))
    end

    private

    def index_object
      SphinxIndexationWorker.perform_later(self.class, id)
    end
  end
end
