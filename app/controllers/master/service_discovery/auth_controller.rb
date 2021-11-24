# frozen_string_literal: true

class Master::ServiceDiscovery::AuthController < Master::BaseController
  include SiteAccountSupport
  def show
    self_domain = params.require(:self_domain)

    redirect_to self_domain_url(self_domain)
  end

  protected

  def self_domain_url(self_domain)
    options = params.permit(%i[code referrer state]).to_h.merge(host: self_domain, controller: 'provider/admin/service_discovery/auth', action: :show)
    url_for(options)
  end
end
