# frozen_string_literal: true

class Api::ProxyRulesIndexPresenter < ProxyRulesIndexBasePresenter
  attr_reader :service

  def initialize(service:, params:)
    @service = service
    super(proxy: service.proxy, params: params)
  end

  def new_rule_path
    new_admin_service_proxy_rule_path(service)
  end
end
