# frozen_string_literal: true

module Api::BackendUsagesHelper
  def add_backend_usage_form_data
    {
      backends: backends_data.to_json,
      url: admin_service_backend_usages_path(@service),
      'new-backend-path': new_provider_admin_backend_api_path
    }
  end

  def backends_data
    current_account.backend_apis
                   .accessible
                   .not_used_by(@backend_api_config.service_id)
                   .order(updated_at: :desc)
                   .decorate
                   .map do |backend|
                     {
                       id: backend.id,
                       name: backend.name,
                       privateEndpoint: backend.private_endpoint,
                       updatedAt: backend.updated_at
                     }
                   end
  end
end
