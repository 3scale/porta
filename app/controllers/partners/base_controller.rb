# frozen_string_literal: true

class Partners::BaseController < ApplicationController

  include SiteAccountSupport
  skip_before_action :verify_authenticity_token
  before_action :authenticate!

  private

  attr_reader :partner

  def authenticate!
    @partner = Partner.find_by(api_key: params.require(:api_key))
    render(plain: 'unauthorized', status: :unauthorized) unless @partner
  end
end
