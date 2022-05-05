# frozen_string_literal: true

class QuickstartsPresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(current_api)
    raise ArgumentError, 'Undefined current API' if current_api.nil?

    @current_api = current_api
  end

  attr_reader :current_api

  # Consumed by app/javascript/src/QuickStarts/utils/replaceLinksExtension.js
  def links
    [
      ['create-a-product-link', new_admin_service_path, 'Create a product'],
      ['create-a-backend-link', new_provider_admin_backend_api_path, 'Create a backend'],
      ['create-an-application-plan-link', new_admin_service_application_plan_path(current_api), 'Create an application plan'],
      ['create-a-method-link-in-create-mapping-rules', new_admin_service_metric_child_path(current_api, current_api.metrics.hits), 'Create a method']
    ].to_json
  end
end
