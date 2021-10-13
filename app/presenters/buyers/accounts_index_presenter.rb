# frozen_string_literal: true

class Buyers::AccountsIndexPresenter
  def initialize(provider:, params: {})
    @provider = provider
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @search = ThreeScale::Search.new(params[:search])
    @sorting_params = [params[:sort] || 'created_at', params[:direction] || 'desc']
  end

  attr_reader :provider, :pagination_params, :search, :sorting_params

  delegate :total_entries, to: :buyers

  def buyers
    @buyers ||= provider.buyer_accounts
                        .not_master
                        .scope_search(search)
                        .order_by(*sorting_params)
                        .paginate(pagination_params)
  end

  alias paginated_buyers buyers

  # The JSON response of index endpoint is used to populate NewApplicationForm's BuyerSelect
  def render_json
    {
      items: buyers.map { |a| BuyerPresenter.new(a).new_application_data.as_json }.to_json,
      count: total_entries
    }
  end
end
