# frozen_string_literal: true

class Api::ServicesIndexPresenter
  def initialize(user:, search_params: nil, pagination_params: nil)
    @user = user
    @pagination_params = pagination_params
    @search = ThreeScale::Search.new(search_params)
  end

  attr_reader :user, :pagination_params, :search

  def products_data
    {
      products: paginated_services.to_json(only: %i[name updated_at id system_name], methods: %i[links apps_count backends_count unread_alerts_count]),
      'products-count': paginated_services.total_entries
    }
  end

  def paginated_services
    @paginated_services ||= user.accessible_services
                                .order(updated_at: :desc)
                                .scope_search(search)
                                .paginate(pagination_params)
                                .decorate
  end
end
