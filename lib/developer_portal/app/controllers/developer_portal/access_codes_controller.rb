# frozen_string_literal: true

class DeveloperPortal::AccessCodesController < ApplicationController

  #TODO: if AccessCodeProtection would be splitted in more modules this wouldn't be needed

  include SiteAccountSupport
  include AccessCodeProtection
  skip_before_action :protect_access

  include Liquid::TemplateSupport
  include Liquid::Assigns

  layout false

  def show
    # no need to do anything as DP is not protected by access code
    return(redirect_to(return_url)) if no_access_code?

    show_params = params.permit(access_code_param).to_h
    if show_params[access_code_param].presence == access_code
      cookies[access_code_param] = show_params[access_code_param]
      redirect_return_url = return_url
      session[:return_to] = nil
      redirect_to redirect_return_url
    else
      store_location if request.path != access_code_path && !session[:return_to]
    end
  end

  private

  def cms_params
    params.permit(:cms_token, :cms)
  end

  def return_url
    return_to = params.permit(:return_to).to_h[:return_to] || session[:return_to]
    if return_to.blank? || return_to == access_code_path
      root_url(cms_params)
    else
      safe_return_to(return_to)
    end
  end

  def safe_return_to(url)
    safe_url = URI(root_url)
    safe_url.path = url
    safe_url.query = cms_params.to_query
    safe_url.to_s
  rescue URI::InvalidComponentError
    root_url
  end
end
