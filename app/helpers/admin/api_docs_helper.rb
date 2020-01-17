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
end
