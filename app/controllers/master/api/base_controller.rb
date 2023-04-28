# frozen_string_literal: true

class Master::Api::BaseController < Master::BaseController
  include ApiAuthentication::ByProviderKey
  include ApiSupport::PrepareResponseRepresenter
  include ApiSupport::Params
  include SiteAccountSupport

  before_action :authenticate!

  private

  def provider_key_param_name
    :api_key
  end

  def authenticate!
    render plain: 'unauthorized', status: 401 unless logged_in?
  end

  def api_controller?
    true
  end
end
