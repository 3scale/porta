# frozen_string_literal: true

module Admin::ApiDocsHelper
  def new_api_docs_service_path(service = nil)
    service.present? ? new_admin_service_api_doc_path(service) : new_admin_api_docs_service_path
  end

  def create_api_docs_service_path(service = nil)
    service.present? ? admin_service_api_docs_path(service) : admin_api_docs_services_path
  end

  def update_api_docs_service_path(api_doc)
    service = api_doc.service
    service.present? ? admin_service_api_doc_path(service, api_doc) : admin_api_docs_service_path(api_doc)
  end

  def spec_url(api_docs_service)
    base_url.gsub(%r{/$}, '').concat(admin_api_docs_service_path(api_docs_service, format: :json))
  end

  # FIXME: this smells of :reek:FeatureEnvy so maybe move it to a presenter
  def api_docs_service_data(api_docs_service) # rubocop:disable Metrics/AbcSize
    data = {
      apiJsonSpec: api_docs_service.body || '',
      description: api_docs_service.description || '',
      errors: api_docs_service.errors.messages.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym },
      isUpdate: !api_docs_service.new_record?,
      name: api_docs_service.name || '',
      published: api_docs_service.published,
      skipSwaggerValidations: api_docs_service.skip_swagger_validations.presence || false,
      systemName: api_docs_service.system_name || '',
      action: data_url(api_docs_service)
    }

    if requires_service(current_scope, api_docs_service)
      data[:collection] = current_user.accessible_services.as_json(only: %i[id name], root: false)
      data[:serviceId] = api_docs_service.service_id
    end

    data
  end

  protected

  def data_url(api_docs_service)
    api_docs_service.new_record? ? create_api_docs_service_path(api_docs_service.service) : update_api_docs_service_path(api_docs_service)
  end

  def requires_service(current_scope, api_docs_service)
    !current_scope.is_a?(Service) || !api_docs_service.new_record?
  end
end
