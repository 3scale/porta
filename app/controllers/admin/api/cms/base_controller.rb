class Admin::Api::CMS::BaseController < Admin::Api::BaseController

  before_action :deny_on_premises_for_master
  self.access_token_scopes = %i[cms account_management]

  MAX_PER_PAGE = 100
  DEFAULT_PER_PAGE = 20

  private

  def per_page
    if per_page_params[:per_page].present?
      [per_page_params[:per_page].to_i, MAX_PER_PAGE].min
    else
      DEFAULT_PER_PAGE
    end
  end

  def per_page_params
    params.permit(:per_page).to_h
  end

  def page_params
    params.permit(:page).to_h
  end
end
