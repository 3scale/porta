# frozen_string_literal: true

class Admin::Api::PoliciesController < Admin::Api::BaseController

  before_action :authorize_rolling_update

  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/policies.json"
  ##~ e.responseClass = "json"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "APIcast Policy Registry"
  ##~ op.description = "Returns APIcast Policy Registry"
  ##~ op.group = "apicast_policies"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def index
    policies = Policies::PoliciesListService.call(current_account)

    respond_to do |format|
      format.json { render json: policies }
    end
  end

  private

  def authorize_rolling_update
    provider_can_use!(:policies)
  end
end
