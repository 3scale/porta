# frozen_string_literal: true

class Api::ServicesIndexPresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(current_user:, params: {})
    @current_user = current_user
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @search = ThreeScale::Search.new(params[:search])
    @sorting_params = "#{params[:sort].presence || 'updated_at'} #{params[:direction].presence || 'desc'}"
  end

  attr_reader :current_user, :pagination_params, :search, :sorting_params

  delegate :total_entries, to: :products

  def products
    @products ||= current_user.accessible_services
                              .order(sorting_params)
                              .scope_search(search)
                              .paginate(pagination_params)
  end

  alias paginated_products products

  def data
    {
      'new-product-path': new_admin_service_path,
      products: products.map { |p| ServicePresenter.new(p).index_data.as_json }.to_json,
      'products-count': total_entries
    }
  end

  def dashboard_widget_data
    {
      products: products.map { |p| ServicePresenter.new(p).dashboard_widget_data.as_json },
      newProductPath: new_admin_service_path,
      productsPath: admin_services_path
    }
  end

  # The JSON response of index endpoint is used to populate NewApplicationForm's BuyerSelect
  def render_json
    {
      items: products.map { |p| ServicePresenter.new(p).new_application_data.as_json }.to_json,
      count: total_entries
    }
  end
end
