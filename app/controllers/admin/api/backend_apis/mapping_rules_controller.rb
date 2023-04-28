# frozen_string_literal: true

class Admin::Api::BackendApis::MappingRulesController < Admin::Api::BackendApis::BaseController
  represents :json, entity: ::ProxyRuleRepresenter::JSON, collection: ::ProxyRulesRepresenter::JSON
  wrap_parameters ProxyRule, name: :mapping_rule

  # Backend Mapping Rules List
  # GET /admin/api/backend_apis/{backend_api_id}/mapping_rules.json
  def index
    respond_with(backend_api.mapping_rules.order(:id).paginate(pagination_params))
  end

  # Backend Mapping Rules Read
  # GET /admin/api/backend_apis/{backend_api_id}/mapping_rules/{id}.json
  def show
    respond_with(mapping_rule)
  end

  # Backend Mapping Rule Create
  # POST /admin/api/backend_apis/{backend_api_id}/mapping_rules.json
  def create
    mapping_rule = backend_api.mapping_rules.create(mapping_rule_params)
    respond_with(mapping_rule)
  end

  # Backend Mapping Rule Update
  # PUT /admin/api/backend_apis/{backend_api_id}/mapping_rules/{id}.json
  def update
    mapping_rule.update(mapping_rule_params)
    respond_with(mapping_rule)
  end

  # Backend Mapping Rule Delete
  # DELETE /admin/api/backend_apis/{backend_api_id}/mapping_rules/{id}.json
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
