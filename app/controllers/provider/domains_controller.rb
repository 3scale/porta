class Provider::DomainsController < Provider::BaseController

  before_action :disable_x_frame
  skip_before_action :login_required

  layout 'provider/iframe'

  def recover
    domains = site_account.managed_users.where(email: params[:email]).map{|p| p.account.self_domain}.uniq

    ProviderUserMailer.lost_domain(params[:email], domains).deliver_later unless domains.empty?
  end
end
