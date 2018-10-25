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
      success_update
    else
      respond_to do |format|
        format.html do
          render :edit
        end

        format.js { render template: '/provider/admin/cms/templates/update' }
      end
    end
  rescue ActiveModel::MassAssignmentSecurity::Error => error
    draft_error = DraftAttributeNotSavedError.new(error, @page, template_params)
    System::ErrorReporting.report_error(draft_error)

    @page.draft = template_params[:draft]
    @page.save

    success_update
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

  def success_update
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
  end

  class DraftAttributeNotSavedError < StandardError
    include Bugsnag::MetaData

    attr_reader :original_exception

    def initialize(original_exception, page, template_params)
      @original_exception = original_exception

      self.bugsnag_meta_data = {
        template_params: template_params,
        page: {
          class_name:             page.class.name,
          accessible_attributes:  page.class.accessible_attributes,
          _accessible_attributes: page._accessible_attributes,
          _protected_attributes:  page._protected_attributes,
          attributes:             page.attributes,
          errors:                 page.errors.messages
        }
      }
    end
  end

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
