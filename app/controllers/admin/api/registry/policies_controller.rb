# frozen_string_literal: true

class Admin::Api::Registry::PoliciesController < Admin::Api::BaseController
  self.access_token_scopes = :policy_registry

  clear_respond_to
  respond_to :json

  representer ::Policy

  before_action :authorize_policies
  before_action :find_policy, only: %i[show update destroy]

  # swagger
  ##~ sapi = source2swagger.namespace("Policy Registry API")
  ##~ sapi.basePath = @base_path
  ##~ @parameter_policy_id = { :name => "id", :description => "ID of the policy. It can be an integer value or a combination 'name-version' of the policy (e.g. 'mypolicy-1.0')", :dataType => "string", :required => true, :paramType => "path" }

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/registry/policies.json"
  ##~ e.responseClass = "policy"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "APIcast Policy Registry List"
  ##~ op.description = "List the APIcast Policies"
  ##~ op.group = "apicast_policies"
  #
  ##~ op.parameters.add @parameter_access_token
  def index
    respond_with current_account.policies
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/registry/policies.json"
  ##~ e.responseClass = "policy"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "APIcast Policy Registry Create"
  ##~ op.description = "Creates an APIcast Policy"
  ##~ op.group = "apicast_policies"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "name", :description => "Name of the policy", :required => true, :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "version", :description => "Version of the policy", :required => true, :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "schema", :description => "JSON Schema of the policy", :required => true, :dataType => "string", :paramType => "query"
  #
  def create
    respond_with current_account.policies.create(policy_params)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/registry/policies/{id}.json"
  ##~ e.responseClass = "policy"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "APIcast Policy Registry Read"
  ##~ op.description = "Returns the APIcast policy by ID"
  ##~ op.group       = "apicast_policies"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_policy_id
  def show
    respond_with(policy)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/registry/policies/{id}.json"
  ##~ e.responseClass = "policy"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "PUT"
  ##~ op.summary     = "APIcast Policy Registry Update"
  ##~ op.description = "Updates an APIcast Policy"
  ##~ op.group       = "apicast_policies"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_policy_id
  ##~ op.parameters.add :name => "name", :description => "New name of the policy", :required => false, :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "version", :description => "New version of the policy", :required => false, :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "schema", :description => "New JSON Schema of the policy", :required => false, :dataType => "string", :paramType => "query"
  def update
    policy.update_attributes(policy_params)
    respond_with(policy)
  end

  ##~ op             = e.operations.add
  ##~ e.path = "/admin/api/registry/policies/{id}.json"
  ##~ e.responseClass = "policy"
  #
  ##~ op.httpMethod  = "DELETE"
  ##~ op.summary     = "APIcast Policy Registry Delete"
  ##~ op.description = "Deletes an APIcast policy by ID"
  ##~ op.group       = "apicast_policies"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_policy_id
  def destroy
    policy.destroy
    respond_with(policy)
  end

  private

  attr_reader :policy

  def authorize_policies
    authorize! :manage, :policy_registry
  end

  def policy_params
    policy_params = params.require(:policy)
    final_params = policy_params.permit(:name, :version)
    final_params.merge(schema: policy_params.require(:schema)).permit!
  end

  def find_policy
    @policy ||= current_account.policies.find_by_id_or_name_version!(params[:id])
  end
end
