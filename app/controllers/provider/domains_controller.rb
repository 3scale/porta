class Provider::DomainsController < Provider::BaseController

  before_action :disable_x_frame
  skip_before_action :login_required

  layout 'provider/iframe'

  def recover
    email_param = params.require(:email)
    domains = site_account.managed_users.where(email: email_param).map{|p| p.account.external_admin_domain}.uniq

    ProviderUserMailer.lost_domain(email_param, domains).deliver_later unless domains.empty?
  end
end
