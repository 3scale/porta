class Provider::Admin::CMS::TemplatesController < Provider::Admin::CMS::BaseController
  activate_menu :audience, :cms, :content

  def index
  end

  def new
    @page ||= templates.new
  end

  def edit
    @page ||= templates.find(params[:id])
  end

  def create
    @page ||= templates.build
    @page.attributes = template_params

    if @page.save
      flash[:info] = "#{@page.class.model_name.human} created."
      redirect_to( :action => :edit, :id => @page.id)
    else
      render :new
    end
  end

  def update
    @page ||= templates.find(params[:id])

    @page.assign_attributes(template_params, without_protection: true)
    @page.build_version if params[:version]

    if @page.save
      msg = publish_or_hide_page_with_message
      respond_to do |format|
        format.html do
          flash[:notice] = msg
          redirect_to(action: :edit, id: @page.id)
        end

        format.js do
          flash.now[:notice] = msg
          render template: '/provider/admin/cms/templates/update'
        end
      end
    else
      respond_to do |format|
        format.html { render :edit }

        format.js { render template: '/provider/admin/cms/templates/update' }
      end
    end
  end

  # TODO: - deprecated? remove?
  def publish
    @page ||= templates.find(params[:id])
    @page.publish!
    redirect_to :action => :edit, :id => @page.id
  end

  def destroy
    @page ||= templates.find(params[:id])
    @page.destroy
    redirect_to provider_admin_cms_templates_path
  end

  def sidebar
    if latest = latest_update
      fresh_when(:etag => latest, :last_modified => latest.utc)
    end

    if request.fresh?(response)
      return
    else
      respond_to do |format|
        format.json { render json: CMS::Sidebar.new(current_account) }
      end
    end
  end

  private

  def latest_update
    CMS::Sidebar.new(current_account).last_update
  end

  def publish_or_hide_page_with_message
    if params[:publish]
      @page.publish!
      return "#{@page.class.model_name.human} saved and published."
    elsif params[:hide]
      @page.hide!
      return "#{@page.class.model_name.human} has been hidden."
    else
      return "#{@page.class.model_name.human} saved."
    end
  end

  def template_params
    params.require(:cms_template).permit(:draft, :liquid_enabled, :handler, :system_name, :title)
  end

  def templates
    current_account.templates
  end
end
