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

    redirect_to({ action: :index }, success: t('.success'))
  end

  def revert
    if page.revert_to(version).save
      redirect_to polymorphic_path([:edit, :provider, :admin, @page]), success: t('.success', date: l(version.created_at))
    else
      redirect_back_or_to provider_admin_cms_template_version_path(@page, version), danger: t('.error')
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
