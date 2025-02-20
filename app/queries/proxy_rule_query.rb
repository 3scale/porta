# frozen_string_literal: true

class ProxyRuleQuery
  DEFAULT_SEARCH_OPTIONS = {
    ids_only: true, per_page: ThreeScale::Search::Helpers::SPHINX_PAGE_SIZE_INFINITE, ignore_scopes: true
  }.freeze

  def initialize(owner_type:, owner_id:, sort: nil, direction: nil)
    @direction  = direction
    @owner_type = owner_type
    @owner_id   = owner_id
    @sort       = sort
  end

  def search_for(query, scope = ProxyRule.all)
    scope = scope.order_by(@sort, @direction).includes(:metric)
    return scope if query.blank?

    options = DEFAULT_SEARCH_OPTIONS.merge(with: { owner_type: @owner_type, owner_id: @owner_id })
    ids = ProxyRule.search(ThinkingSphinx::Query.escape(query), options)
    scope.where(id: ids, owner_type: @owner_type, owner_id: @owner_id)
  end
end
