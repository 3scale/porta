# frozen_string_literal: true

class Api::ServicesIndexPresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(user:, params: {})
    @user = user
    @ability = Ability.new(user)
    @params = params

    @products = build_products_query
  end

  attr_reader :products

  alias paginated_products products

  delegate :total_entries, to: :products

  def data # rubocop:disable Metrics/AbcSize
    {
      'new-product-path': can_create_service ? new_admin_service_path : nil,
      products: products.map do |product|
        {
          id: product.id,
          name: product.name,
          systemName: product.system_name,
          updatedAt: product.updated_at.to_fs(:long),
          link: product.decorate.link,
          links: ServiceActionsPresenter.new(user).actions(product),
          appsCount: product.cinstances.size,
          backendsCount: product.backend_api_configs.size,
          unreadAlertsCount: product.decorate.unread_alerts_count
        }
      end.to_json,
      'products-count': total_entries
    }
  end

  def render_json
    return compact_json if params[:compact]

    {
      items: products.includes(:default_application_plan).map { |p| ServicePresenter.new(p).new_application_data.as_json }.to_json,
      count: total_entries
    }
  end


  private

  attr_reader :user, :ability, :params

  def build_products_query
    filtered_products = filter_products(user.accessible_services)
    filtered_products.order(sorting_params)
                     .scope_search(search_params)
                     .paginate(pagination_params)
  end

  def filter_products(accessible_services)
    return accessible_services.where(support_email: nil) if params[:without_support_emails]

    accessible_services
  end

  def pagination_params
    {
      page: params[:page] || 1,
      per_page: params[:per_page] || 20
    }
  end

  def search_params
    ThreeScale::Search.new(params[:search])
  end

  def sorting_params
    sort_field = params[:sort].presence || :updated_at
    direction = params[:direction].presence || :desc
    "#{sort_field} #{direction}"
  end

  def compact_json
    {
      items: products.decorate.to_json(only: %i[id name system_name updated_at], js: true),
      count: total_entries
    }
  end

  delegate :can?, to: :ability

  # See https://github.com/3scale/porta/blob/27c0e3ab66e6d589412b2e87ee86e32c1f7f5390/app/controllers/api/services_controller.rb#L165
  def can_create_service
    can?(:create, Service)
  end
end
