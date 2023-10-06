# frozen_string_literal: true

class Provider::Admin::Account::EmailConfigurationsPresenter
  include System::UrlHelpers.system_url_helpers

  delegate :email_configurations, to: :provider
  delegate :errors, to: :email_configuration

  def initialize(provider:, email_configuration: nil, params: {})
    @provider = provider
    @email_configuration = email_configuration
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @sorting_params = "#{params[:sort] || 'id'} #{params[:direction] || 'desc'}"
    @search = ThreeScale::Search.new(params[:search] || params)
  end

  attr_reader :provider, :email_configuration, :pagination_params, :sorting_params, :search

  def index_data
    {
      'new-email-configuration-path': new_provider_admin_account_email_configuration_path,
      'email-configurations': page_email_configurations.to_json,
      'email-configurations-count': paginated_collection.total_entries
    }
  end

  def new_data
    {
      url: provider_admin_account_email_configurations_path,
      'email-configuration': EmailConfigurationPresenter.new(email_configuration).form_data.to_json,
      errors: errors.to_json
    }
  end

  def edit_data
    {
      url: provider_admin_account_email_configuration_path(email_configuration),
      'email-configuration': EmailConfigurationPresenter.new(email_configuration).edit_form_data.to_json,
      errors: errors.to_json
    }
  end

  def collection
    @collection ||= email_configurations.scope_search(search)
                                        .order(sorting_params)
  end

  protected

  def paginated_collection
    collection.paginate(pagination_params)
  end

  def page_email_configurations
    paginated_collection.map { |ec| EmailConfigurationPresenter.new(ec).index_table_data }
  end
end
