class Provider::Admin::CMS::VersionsController < Provider::Admin::CMS::BaseController

  activate_menu :audience, :cms

  def index
    @page = page
    @versions = @page.versions.order('created_at DESC, id ASC').paginate(:page => params[:page])
  end

  def show
    @page = page
    @version  = version
  end

  def destroy
    version.destroy

    flash[:notice] = "Version was destroyed"
    redirect_to :action => :index
  end

  def revert
    if page.revert_to(version).save
      flash[:notice] = "Reverted to version from #{I18n.l(version.created_at)}"
      redirect_to polymorphic_path([:edit, :provider, :admin, @page])
    else
      flash[:error] = "Problem reverting version"
      redirect_to :back
    end
  end

  private

  def version
    @version ||= page.versions.find(params[:id])
  end

  def page
    @page ||= current_account.templates.find(params[:template_id])
  end

end
