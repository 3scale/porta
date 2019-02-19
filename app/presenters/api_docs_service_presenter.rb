# frozen_string_literal: true

class ApiDocsServicePresenter
  DELEGATED_METHODS = ApiDocs::Service.attribute_names.map(&:to_sym) | %i[service base_path specification swagger_version]
  delegate(*DELEGATED_METHODS, to: :api_docs_service)

  def initialize(api_docs_service)
    @api_docs_service = api_docs_service
  end

  def host_with_port
    return unless service
    return unless (endpoint = service.proxy.endpoint)
    uri = Addressable::URI.parse(endpoint)
    "#{uri.normalized_host}:#{uri.port}"
  end

  private

  attr_reader :api_docs_service
end
