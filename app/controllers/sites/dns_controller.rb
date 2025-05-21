class Sites::DnsController < Sites::BaseController
  activate_menu :audience, :cms, :admin_site_dns

  before_action :find_account
  before_action :disable_client_cache

  def show
  end

  def update
    if @account.update(site_params, without_protection: true)
      redirect_to admin_site_dns_url, success: t('.success')
    else
      flash.now[:danger] = @account.errors.full_messages.join(' ')
      render :action => 'show'
    end
  end

  def open_portal
    @account.update_attribute(:site_access_code, nil)
    flash.now[:success] = t('.success')
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
