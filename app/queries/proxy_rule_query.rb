# frozen_string_literal: true

class ProxyRuleQuery
  def initialize(owner_type:, owner_id:, sort: nil, direction: nil,
                 per_page: ThreeScale::Search::Helpers::MAX_SEARCH_PAGE_SIZE)
    @direction  = direction
    @owner_type = owner_type
    @owner_id   = owner_id
    @per_page   = per_page.to_i
    @sort       = sort
  end

  def search_for(query, scope = ProxyRule.all)
    scope = scope.order_by(@sort, @direction).includes(:metric)
    return scope if query.blank?

    options = {
      ids_only: true, star: true, per_page: @per_page, ignore_scopes: true,
      with: { owner_type: @owner_type, owner_id: @owner_id }
    }
    ids = ProxyRule.search(ThinkingSphinx::Query.escape(query), options)
    scope.where(id: ids, owner_type: @owner_type, owner_id: @owner_id)
  end
end
