# frozen_string_literal: true

class Admin::Api::Services::MappingRulesController < Admin::Api::Services::BaseController
  ##~ sapi = source2swagger.namespace("Account Management API")

  represents :json, entity: ::ProxyRuleRepresenter::JSON, collection: ::ProxyRulesRepresenter::JSON
  represents :xml, entity: ::ProxyRuleRepresenter::XML, collection: ::ProxyRulesRepresenter::XML

  wrap_parameters ::ProxyRule, name: :mapping_rule

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy/mapping_rules.xml"
  ##~ e.responseClass = "mapping_rule"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Mapping Rules List"
  ##~ op.description = "Returns the Mapping Rules of a Proxy."
  ##~ op.group = "mapping_rule"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  #
  def index
    respond_with(proxy_rules)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy/mapping_rules/{id}.xml"
  ##~ e.responseClass = "mapping_rule"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Mapping Rules Show"
  ##~ op.description = "Returns the Mapping Rule."
  ##~ op.group = "mapping_rule"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add name: "id", description: "Mapping Rule ID.", dataType: "int", paramType: "path", required: true
  #
  def show
    respond_with(proxy_rule)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy/mapping_rules.xml"
  ##~ e.responseClass = "mapping_rule"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Mapping Rule Create"
  ##~ op.description = "Creates a Proxy Mapping Rule. The proxy object needs to be updated after a mapping rule is added to apply the change to the APIcast configuration. If adding multiple mapping rules then only one call to the Proxy Update endpoint is necessary after all mapping rules have been created."
  ##~ op.group = "mapping_rule"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add name: "http_method", description: "HTTP method.", dataType: "string", paramType: "query", required: true
  ##~ op.parameters.add name: "pattern", description: "Mapping Rule pattern.", dataType: "string", paramType: "query", required: true
  ##~ op.parameters.add name: "delta", description: "Increase the metric by this delta.", dataType: "int", paramType: "query", required: true
  ##~ op.parameters.add name: "metric_id", description: "Metric ID.", dataType: "int", paramType: "query", required: true, threescale_name: "metric_ids"
  ##~ op.parameters.add name: "position", description: "Mapping Rule position", dataType: "int", paramType: "query"
  ##~ op.parameters.add name: "last", description: "Last matched Mapping Rule to process", dataType: "bool", paramType: "query"
  #
  def create
    proxy_rule = proxy.proxy_rules.create(proxy_rule_params)

    respond_with(proxy_rule)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy/mapping_rules/{id}.xml"
  ##~ e.responseClass = "mapping_rule"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PATCH"
  ##~ op.summary    = "Mapping Rule Update"
  ##~ op.description = "Updates a Proxy Mapping Rule. The proxy object needs to be updated after a mapping rule is updated to apply the change to the APIcast configuration. If updating multiple mapping rules then only one call to the Proxy Update endpoint is necessary after all mapping rules have been updated."
  ##~ op.group = "mapping_rule"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add name: "id", description: "Mapping Rule ID.", dataType: "int", paramType: "path", required: true
  ##~ op.parameters.add name: "http_method", description: "HTTP method.", dataType: "string", paramType: "query"
  ##~ op.parameters.add name: "pattern", description: "Mapping Rule pattern.", dataType: "string", paramType: "query"
  ##~ op.parameters.add name: "delta", description: "Increase the metric by this delta.", dataType: "int", paramType: "query"
  ##~ op.parameters.add name: "metric_id", description: "Metric ID.", dataType: "int", paramType: "query", threescale_name: "metric_ids"
  ##~ op.parameters.add name: "position", description: "Mapping Rule position", dataType: "int", paramType: "query"
  ##~ op.parameters.add name: "last", description: "Last matched Mapping Rule to process", dataType: "bool", paramType: "query"
  #
  def update
    proxy_rule.update(proxy_rule_params)
    respond_with(proxy_rule)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/proxy/mapping_rules/{id}.xml"
  ##~ e.responseClass = "mapping_rule"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Mapping Rule Delete"
  ##~ op.description = "Deletes a Proxy Mapping Rule. The proxy object needs to be updated after a mapping rule is deleted to apply the change to the APIcast configuration. If deleting multiple mapping rules then only one call to the Proxy Update endpoint is necessary after all desired mapping rules have been deleted."

  ##~ op.group = "mapping_rule"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add name: "id", description: "Mapping Rule ID.", dataType: "int", paramType: "path", required: true
  #
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
