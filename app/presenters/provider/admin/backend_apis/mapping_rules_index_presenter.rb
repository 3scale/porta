# frozen_string_literal: true

class Provider::Admin::BackendApis::MappingRulesIndexPresenter < ProxyRulesIndexBasePresenter
  attr_reader :backend_api

  def initialize(backend_api:, params:)
    @backend_api = backend_api
    super(proxy: backend_api, params: params)
  end

  def new_rule_path
    new_provider_admin_backend_api_mapping_rule_path(backend_api)
  end
end
