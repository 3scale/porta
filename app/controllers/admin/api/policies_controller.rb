# frozen_string_literal: true

class Admin::Api::PoliciesController < Admin::Api::BaseController

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
end
