# frozen_string_literal: true

class Api::ProxyRulesIndexPresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(proxy:, params: {})
    @proxy = proxy

    @search = ThreeScale::Search.new(params[:search])
    @query = ProxyRuleQuery.new(owner_type: params[:owner_type],
                                owner_id: proxy.id,
                                direction: params[:direction] || 'desc',
                                sort: params[:sort] || 'created_at')

    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
  end

  attr_reader :proxy, :search, :query, :pagination_params

  def proxy_rules
    @proxy_rules ||= query.search_for(@search['query'], raw_proxy_rules)
                          .paginate(pagination_params)
  end

  def empty_state?
    raw_proxy_rules.empty?
  end

  def empty_search_state?
    proxy_rules.empty?
  end

  def toolbar_props
    {
      totalEntries: proxy_rules.total_entries,
      actions: [],
      overflow: nil,
      search: {
        placeholder: 'Search for pattern'
      },
      filters: []
    }
  end

  private

  def raw_proxy_rules
    @raw_proxy_rules ||= proxy.proxy_rules.includes(:metric)
  end
end
