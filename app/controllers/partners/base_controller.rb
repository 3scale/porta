class Partners::BaseController < ApplicationController

  include SiteAccountSupport
  skip_before_action :verify_authenticity_token
  before_action :authenticate!

  private

  attr_reader :partner

  def authenticate!
    @partner = Partner.find_by(api_key: params.permit(:api_key)[:api_key])
    render(plain: 'unauthorized', status: 401) unless @partner
  end
end
