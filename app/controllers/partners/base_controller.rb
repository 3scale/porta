class Partners::BaseController < ApplicationController

  include SiteAccountSupport
  skip_before_action :verify_authenticity_token
  before_action :authenticate!

  private

  def authenticate!
    unless @partner = Partner.find_by_api_key(params[:api_key])
      render plain: 'unauthorized', status: 401
    end
  end
end
