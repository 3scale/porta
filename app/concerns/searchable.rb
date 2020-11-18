# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    include ThreeScale::Search::Scopes

    after_save :index_object
    after_destroy :index_object

    self.allowed_search_scopes = %i[query]

    scope :by_query, ->(query) do
      options = { ids_only: true, per_page: 1_000_000, star: false, ignore_scopes: true, with: {} }
      term = "@!sphinx_internal_class_name #{ThinkingSphinx::Query.wildcard(ThinkingSphinx::Query.escape(query))}"
      where(id: search(term, options))
    end

    private

    def index_object
      SphinxIndexationWorker.perform_later(self)
    end
  end
end
