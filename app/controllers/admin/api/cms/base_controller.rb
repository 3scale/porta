class Admin::Api::CMS::BaseController < Admin::Api::BaseController

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
end
