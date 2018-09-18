# Include this into a controller to enable protection with site access code.
#
# This requires
#   * SiteAccountSupport for site_account
#   * AuthenticatedSystem for store_location
#
module AccessCodeProtection

  ACCEPTABLE_TYPES = [:xml, :json]

  #TODO: this module could be splitted into more modules, one having only the before_action
  # that way the access_code_controller won't need to bypass the before_action
  def self.included(base)
    base.prepend_before_action :protect_access
    base.helper_method :access_code_param
  end

  private

  def protect_access
    unless access_code_valid?
      store_location unless request.fullpath == access_code_path
      render :template => 'developer_portal/access_codes/show', :layout => false
    end
  end

  def access_code_valid?
    return true if request.method == 'OPTIONS'.freeze
    return true if request.format && ACCEPTABLE_TYPES.include?(request.format.to_sym)

    return true if no_access_code?

    cookies[access_code_param] == access_code
  end

  def no_access_code?
    access_code.blank?
  end

  def access_code
    access_code = site_account.site_access_code
    access_code.presence || ThreeScale.config.access_code
  end

  def access_code_param
    :access_code
  end
end
