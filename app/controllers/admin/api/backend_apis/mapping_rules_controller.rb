# frozen_string_literal: true

class Admin::Api::BackendApis::MappingRulesController < Admin::Api::BackendApis::BaseController
  represents :json, entity: ::ProxyRuleRepresenter::JSON, collection: ::ProxyRulesRepresenter::JSON
  wrap_parameters ProxyRule, name: :mapping_rule

  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/mapping_rules.json"
  ##~ e.responseClass = "List[mapping_rule]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Backend Mapping Rules List"
  ##~ op.description = "Returns the Mapping Rules of a Backend."
  ##~ op.group = "mapping_rule"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add @parameter_page
  ##~ op.parameters.add @parameter_per_page
  #
  def index
    respond_with(backend_api.mapping_rules.order(:id).paginate(pagination_params))
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/mapping_rules/{id}.json"
  ##~ e.responseClass = "mapping_rule"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Backend Mapping Rules Read"
  ##~ op.description = "Returns the Mapping Rule of a Backend."
  ##~ op.group = "mapping_rule"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add @parameter_mapping_rule_id_by_id
  #
  def show
    respond_with(mapping_rule)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/mapping_rules.json"
  ##~ e.responseClass = "mapping_rule"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Backend Mapping Rule Create"
  ##~ op.description = "Creates a Mapping Rule of a Backend."
  ##~ op.group = "mapping_rule"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add name: "http_method", description: "HTTP method.", dataType: "string", paramType: "query", required: true
  ##~ op.parameters.add name: "pattern", description: "Mapping Rule pattern.", dataType: "string", paramType: "query", required: true
  ##~ op.parameters.add name: "delta", description: "Increase the metric by this delta.", dataType: "int", paramType: "query", required: true
  ##~ op.parameters.add name: "metric_id", description: "Metric ID.", dataType: "int", paramType: "query", required: true, threescale_name: "metric_ids"
  ##~ op.parameters.add name: "position", description: "Mapping Rule position", dataType: "int", paramType: "query"
  ##~ op.parameters.add name: "last", description: "Last matched Mapping Rule to process", dataType: "bool", paramType: "query"
  #
  def create
    mapping_rule = backend_api.mapping_rules.create(mapping_rule_params)
    respond_with(mapping_rule)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/mapping_rules/{id}.json"
  ##~ e.responseClass = "mapping_rule"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Backend Mapping Rule Update"
  ##~ op.description = "Updates a Mapping Rule of a Backend."
  ##~ op.group = "mapping_rule"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add @parameter_mapping_rule_id_by_id
  ##~ op.parameters.add name: "http_method", description: "HTTP method.", dataType: "string", paramType: "query"
  ##~ op.parameters.add name: "pattern", description: "Mapping Rule pattern.", dataType: "string", paramType: "query"
  ##~ op.parameters.add name: "delta", description: "Increase the metric by this delta.", dataType: "int", paramType: "query"
  ##~ op.parameters.add name: "metric_id", description: "Metric ID.", dataType: "int", paramType: "query", threescale_name: "metric_ids"
  ##~ op.parameters.add name: "position", description: "Mapping Rule position", dataType: "int", paramType: "query"
  ##~ op.parameters.add name: "last", description: "Last matched Mapping Rule to process", dataType: "bool", paramType: "query"
  #
  def update
    mapping_rule.update(mapping_rule_params)
    respond_with(mapping_rule)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/mapping_rules/{id}.json"
  ##~ e.responseClass = "mapping_rule"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Backend Mapping Rule Delete"
  ##~ op.description = "Deletes a Mapping Rule of a Backend."

  ##~ op.group = "mapping_rule"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add @parameter_mapping_rule_id_by_id
  #
  def destroy
    mapping_rule.destroy
    respond_with(mapping_rule)
  end

  private

  def mapping_rule
    @mapping_rule ||= backend_api.mapping_rules.find(params[:id])
  end

  def mapping_rule_params
    params.require(:mapping_rule).permit(%i[http_method pattern delta last position]).merge(metric_params)
  end

  def metric_params
    return {} unless (metric_id = params.require(:mapping_rule).fetch(:metric_id, nil))
    { metric: backend_api.metrics.find(metric_id) }
  end
 end
