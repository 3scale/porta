# frozen_string_literal: true

class Admin::Api::BackendApis::MappingRulesController < Admin::Api::BaseController
  represents :json, entity: ::ProxyRuleRepresenter::JSON, collection: ::ProxyRulesRepresenter::JSON
  wrap_parameters ProxyRule, name: :mapping_rule

  self.access_token_scopes = :account_management

  before_action :authorize

  clear_respond_to
  respond_to :json

  def index
    respond_with(backend_api.mapping_rules)
  end

  def show
    respond_with(mapping_rule)
  end

  def create
    mapping_rule = backend_api.mapping_rules.create(mapping_rule_params)
    respond_with(mapping_rule)
  end

  def update
    mapping_rule.update(mapping_rule_params)
    respond_with(mapping_rule)
  end

  def destroy
    mapping_rule.destroy
    respond_with(mapping_rule)
  end

  private

  def mapping_rule
    @mapping_rule ||= backend_api.mapping_rules.find(params[:id])
  end

  def backend_api
    @backend_api ||= current_account.backend_apis.find(params[:backend_api_id])
  end

  def authorize
    authorize! :manage, BackendApi
  end

  PERMITTED_PARAMS = %i[http_method pattern delta last position].freeze

  def mapping_rule_params
    params.require(:mapping_rule).permit(PERMITTED_PARAMS).merge(metric_params)
  end

  def metric_params
    return {} unless (metric_id = params.require(:mapping_rule).fetch(:metric_id, nil))
    { metric: backend_api.metrics.find(metric_id) }
  end

 end
