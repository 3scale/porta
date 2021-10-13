# frozen_string_literal: true

class Provider::Admin::BackendApisIndexPresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(current_account:, params: {})
    @current_account = current_account
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @sorting_params = "#{params[:sort].presence || 'updated_at'} #{params[:direction].presence || 'desc'}"
    @search = ThreeScale::Search.new(params[:search])
  end

  attr_reader :current_account, :pagination_params, :sorting_params, :search

  delegate :total_entries, to: :backend_apis

  def backend_apis
    @backend_apis ||= current_account.backend_apis
                                     .order(sorting_params)
                                     .scope_search(search)
                                     .paginate(pagination_params)
  end

  alias paginated_backend_apis backend_apis

  def data
    {
      'new-backend-path': new_provider_admin_backend_api_path,
      backends: backend_apis.map { |s| BackendApiPresenter.new(s).index_data.as_json }.to_json,
      'backends-count': total_entries
    }
  end

  def dashboard_widget_data
    {
      backends: backend_apis.map { |s| BackendApiPresenter.new(s).dashboard_widget_data.as_json }.to_json,
      newBackendPath: new_provider_admin_backend_api_path,
      backendsPath: provider_admin_backend_apis_path
    }
  end
end
