# frozen_string_literal: true

module Api::BackendUsagesHelper
  def add_backend_usage_form_data(service)
    {
      backends: backends(service.id).to_json,
      url: admin_service_backend_usages_path(service),
      'new-backend-path': new_provider_admin_backend_api_path
    }
  end

  def backends(service_id)
    current_account.backend_apis
                   .accessible
                   .not_used_by(service_id)
                   .order(updated_at: :desc)
                   .decorate
                   .map(&:add_backend_usage_backends_data)
  end
end
