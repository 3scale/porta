# frozen_string_literal: true

class Admin::Api::CMS::BaseController < Admin::Api::BaseController
  before_action :ensure_json_request
  before_action :deny_on_premises_for_master
  self.access_token_scopes = %i[cms account_management]

  controller_action_on_unpermitted_parameters :raise
  controller_always_permitted_parameters %i[id page per_page]
  rescue_from ActionController::UnpermittedParameters, with: :error_unpermitted_params

  MAX_PER_PAGE = 100
  DEFAULT_PER_PAGE = 20

  private

  def per_page
    if params[:per_page].present?
      [params[:per_page].to_i, MAX_PER_PAGE].min
    else
      DEFAULT_PER_PAGE
    end
  end

  def ensure_json_request
    raise ActionController::UnknownFormat unless request.format.json?
  end

  def error_unpermitted_params(exception)
    render_error exception.message, status: :unprocessable_entity
  end
end

## Defining common parameters

##~ @parameter_access_token = { :name => "access_token", :description => "Your access token", :dataType => "string", :required => true, :paramType => "query", :allowMultiple => false}
##~ @parameter_page = {:name => "page", :description => "Current page of the list", :dataType => "int", :paramType => "query", :default => 1}
##~ @parameter_per_page = {:name => "per_page", :description => "Total number of records per one page (maximum 100)", :dataType => "int", :paramType => "query", :default => 20}
