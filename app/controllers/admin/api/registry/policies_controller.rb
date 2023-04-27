# frozen_string_literal: true

class Admin::Api::Registry::PoliciesController < Admin::Api::BaseController
  self.access_token_scopes = :policy_registry

  clear_respond_to
  respond_to :json

  representer ::Policy

  before_action :authorize_policies
  before_action :find_policy, only: %i[show update destroy]

  # APIcast Policy Registry List
  # GET /admin/api/registry/policies.json
  def index
    respond_with current_account.policies
  end

  # APIcast Policy Registry Create
  # GET /admin/api/registry/policies.json
  def create
    respond_with current_account.policies.create(policy_params)
  end

  # APIcast Policy Registry Read
  # GET /admin/api/registry/policies/{id}.json
  def show
    respond_with(policy)
  end

  # APIcast Policy Registry Update
  # PUT /admin/api/registry/policies/{id}.json
  def update
    policy.update_attributes(policy_params)
    respond_with(policy)
  end

  # APIcast Policy Registry Delete
  # DELETE /admin/api/registry/policies/{id}.json
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
