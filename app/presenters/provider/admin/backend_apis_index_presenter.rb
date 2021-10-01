# frozen_string_literal: true

class Provider::Admin::BackendApisIndexPresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(current_account:, params: {})
    @current_account = current_account
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @search = ThreeScale::Search.new(params[:search] || params)
  end

  attr_reader :current_account, :pagination_params, :search

  def data
    {
      'new-backend-path': new_provider_admin_backend_api_path,
      backends: page_backend_apis.decorate.map(&:index_page_data).to_json,
      'backends-count': page_backend_apis.total_entries.to_json
    }
  end

  protected

  # TODO: is .order needed?
  def scoped_backen_apis
    @backend_apis ||= current_account.backend_apis
                                     .order(updated_at: :desc)
                                     .scope_search(search)
  end

  def page_backend_apis
    @page_backend_apis ||= scoped_backen_apis.paginate(pagination_params)
  end
end
