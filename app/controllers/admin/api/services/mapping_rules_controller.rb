# frozen_string_literal: true

class Admin::Api::Services::MappingRulesController < Admin::Api::Services::BaseController
  ##~ sapi = source2swagger.namespace("Account Management API")

  represents :json, entity: ::ProxyRuleRepresenter::JSON, collection: ::ProxyRulesRepresenter::JSON
  represents :xml, entity: ::ProxyRuleRepresenter::XML, collection: ::ProxyRulesRepresenter::XML

  wrap_parameters ::ProxyRule, name: :mapping_rule

  # Proxy Mapping Rules List
  # GET /admin/api/services/{service_id}/proxy/mapping_rules.xml
  def index
    respond_with(proxy_rules)
  end

  # Proxy Mapping Rules Show
  # GET /admin/api/services/{service_id}/proxy/mapping_rules/{id}.xml
  def show
    respond_with(proxy_rule)
  end

  # Proxy Mapping Rule Create
  # POST /admin/api/services/{service_id}/proxy/mapping_rules.xml
  def create
    proxy_rule = proxy.proxy_rules.create(proxy_rule_params)

    respond_with(proxy_rule)
  end

  # Proxy Mapping Rule Update
  # PATCH /admin/api/services/{service_id}/proxy/mapping_rules/{id}.xml"
  def update
    proxy_rule.update(proxy_rule_params)
    respond_with(proxy_rule)
  end

  # Proxy Mapping Rule Delete
  # DELETE /admin/api/services/{service_id}/proxy/mapping_rules/{id}.xml"
  def destroy
    proxy_rule.destroy
    respond_with(proxy_rule)
  end

  private

  def proxy_rule
    @_proxy_rule ||= proxy_rules.find(params.require(:id))
  end

  def proxy_rules
    proxy.proxy_rules
  end

  PERMITTED_PARAMS = %i[http_method pattern delta last position].freeze
  PROXY_PRO_PERMITTED_PARAMS = PERMITTED_PARAMS + %i[redirect_url]

  def proxy_rule_params
    params.require(:mapping_rule).permit(permitted_params).merge(metric_params)
  end

  def permitted_params
    if service.using_proxy_pro?
      PROXY_PRO_PERMITTED_PARAMS
    else
      PERMITTED_PARAMS
    end
  end

  def metric_params
    metric_id = params.require(:mapping_rule).fetch(:metric_id) { return {} }

    { metric: service.metrics.find(metric_id) }
  end

  def proxy
    @_proxy ||= service.proxy
  end
end
