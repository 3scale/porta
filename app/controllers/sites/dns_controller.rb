class Sites::DnsController < Sites::BaseController
  sublayout 'sites/developer_portals'
  activate_submenu :portal

  before_action :find_account

  def show
  end

  def update
    if @account.update_attributes(site_params, without_protection: true)
      flash[:notice] = 'The account information was updated.'
      redirect_to(admin_site_dns_url)
    else
      flash[:error] = @account.errors.full_messages.join(' ')
      render :action => 'show'
    end
  end

  def open_portal
    @account.update_attribute(:site_access_code, nil)
    flash.now[:notice] = 'Developer portal opened'
    respond_to do |format|
      format.js
    end
  end

  def contact_3scale
    respond_to do |format|
      format.js { render :layout => false, :content_type => :html }
    end
  end

  private

  def site_params
    permitted_keys = [:site_access_code]
    permitted_keys.concat [:domain, :from_email] unless view_context.readonly_dns_domains?
    params.require(:account).permit(permitted_keys)
  end

  def find_account
    @account = current_account
  end
end
