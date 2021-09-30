# frozen_string_literal: true

class Api::ServicesIndexPresenter
  def initialize(current_user:, params: {})
    @current_user = current_user
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @search = ThreeScale::Search.new(params[:search] || params)
  end

  attr_reader :current_user, :pagination_params, :search

  def data
    {
      products: page_products.decorate.map(&:index_page_data).to_json,
      'products-count': page_products.total_entries.to_json
    }
  end

  protected

  def scoped_products
    @scoped_products ||= current_user.accessible_services
                                     .order(updated_at: :desc)
                                     .scope_search(search)
  end

  def page_products
    @page_products ||= scoped_products.paginate(pagination_params)
  end
end
