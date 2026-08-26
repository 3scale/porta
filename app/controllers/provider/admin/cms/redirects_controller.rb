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
    @redirect = redirects.build(redirect_params)

    if @redirect.save
      redirect_to({ action: :index }, success: t('.success'))
    else
      render :new
    end
  end

  def update
    if redirect.update(redirect_params)
      redirect_to provider_admin_cms_redirects_path, success: t('.success')
    else
      render :edit
    end
  end

  def destroy
    redirect.destroy
    redirect_to provider_admin_cms_redirects_path, success: t('.success')
  end

  private

  def redirect
    @_redirect ||= redirects.find(params[:id])
  end

  def redirects
    @_redirects ||= current_account.redirects
  end

  def redirect_params
    @redirect_params ||= params.require(:cms_redirect).permit(:source, :target)
  end
end
