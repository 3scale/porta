class Provider::Admin::CMS::RedirectsController < Provider::Admin::CMS::BaseController

  sublayout nil
  activate_menu :audience, :cms, :redirects

  def index
    @redirects = redirects
  end

  def new
    @redirect = redirects.new
  end

  def edit
    @redirect = redirect
  end

  def create
    @redirect = redirects.build(params[:cms_redirect])

    if @redirect.save
      flash[:notice] = 'Redirect created.'
      redirect_to :action => :index
    else
      render :new
    end
  end

  def update
    if redirect.update_attributes(params[:cms_redirect])
      redirect_to provider_admin_cms_redirects_path, notice: 'Redirect updated'
    else
      render :edit
    end
  end

  def destroy
    redirect.destroy
    flash[:notice] = 'Redirect deleted.'
    redirect_to provider_admin_cms_redirects_path
  end

  private

  def redirect
    @_redirect ||= redirects.find(params[:id])
  end

  def redirects
    @_redirects ||= current_account.redirects
  end

end
