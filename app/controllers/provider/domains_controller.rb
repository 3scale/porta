# frozen_string_literal: true

class Provider::DomainsController < Provider::BaseController

  before_action :disable_x_frame
  skip_before_action :login_required

  layout 'provider/iframe'

  def recover
    email = params.require(:email)
    domains = site_account.managed_users.where(email: email).map {|p| p.account.self_domain}.uniq

    ProviderUserMailer.lost_domain(email, domains).deliver_now unless domains.empty?
  end
end
