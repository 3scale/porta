# frozen_string_literal: true

class Admin::Api::CMS::BaseController < Admin::Api::BaseController
  include ApiSupport::ForbidParams

  forbid_extra_params :reject, whitelist: %i[id page per_page]

  before_action :ensure_json_request
  before_action :deny_on_premises_for_master
  self.access_token_scopes = %i[cms account_management]

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
end
