class Provider::DomainsController < Provider::BaseController

  skip_before_action :set_x_frame_options_header
  skip_before_action :login_required

  layout 'provider/iframe'

  def recover
    domains = site_account.managed_users.where(email: params[:email]).map{|p| p.account.self_domain}.uniq

    ProviderUserMailer.lost_domain(params[:email], domains).deliver_now unless domains.empty?
  end
end
