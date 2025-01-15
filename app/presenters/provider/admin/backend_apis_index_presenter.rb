# frozen_string_literal: true

class Provider::Admin::BackendApisIndexPresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(user:, params: {})
    @user = user
    @ability = Ability.new(user)

    pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    sorting_params = "#{params[:sort].presence || 'updated_at'} #{params[:direction].presence || 'desc'}"
    search = ThreeScale::Search.new(params[:search])

    @backend_apis = user.accessible_backend_apis
                        .order(sorting_params)
                        .scope_search(search)
                        .paginate(pagination_params)
  end

  attr_reader :backend_apis

  delegate :total_entries, to: :backend_apis

  def data
    {
      'new-backend-path': can?(:create, BackendApi) ? new_provider_admin_backend_api_path : nil,
      backends: backend_apis.map do |backend|
        {
          id: backend.id,
          name: backend.name,
          systemName: backend.system_name,
          updatedAt: backend.updated_at.to_s(:long),
          privateEndpoint: backend.private_endpoint,
          link: backend.decorate.link,
          links: ServiceActionsPresenter.new(user).backend_actions(backend),
          productsCount: backend.decorate.products_count
        }
      end.to_json,
      'backends-count': total_entries
    }
  end

  private

  attr_reader :user, :ability

  delegate :can?, to: :ability
end
