# frozen_string_literal: true

class Admin::Api::PoliciesController < Admin::Api::BaseController

  # APIcast Policy Registry
  # GET /admin/api/policies.json
  def index
    policies = Policies::PoliciesListService.call(current_account)

    respond_to do |format|
      format.json { render json: policies }
    end
  end
end
