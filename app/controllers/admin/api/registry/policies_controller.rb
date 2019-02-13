# frozen_string_literal: true

class Admin::Api::Registry::PoliciesController < Admin::Api::BaseController
  clear_respond_to
  respond_to :json

  representer ::Policy


  # TODO: ApiDocs documentation :)
  def create
    respond_with current_account.policies.create(policy_params)
  end

  private

  def policy_params
    params.require(:policy).permit(:name, :version, :schema)
  end
end
