# frozen_string_literal: true

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
      redirect_to({ action: :edit, id: @page.id }, success: t('provider.admin.cms.templates.created'))
    else
      render :new
    end
  end

  def update # rubocop:disable Metrics/AbcSize
    @page ||= templates.find(params[:id])

    @page.assign_attributes(template_params)
    @page.build_version if params[:version]

    if @page.save
      msg = publish_or_hide_page_with_message
      respond_to do |format|
        format.html { redirect_to({ action: :edit, id: @page.id }, success: msg) }

        format.js do
          flash.now[:success] = msg
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

  protected

  def latest_update
    CMS::Sidebar.new(current_account).last_update
  end

  def publish_or_hide_page_with_message
    if params[:publish]
      @page.publish!
      t('provider.admin.cms.templates.saved_and_published')
    elsif params[:hide]
      @page.hide!
      t('provider.admin.cms.templates.hidden')
    else
      t('provider.admin.cms.templates.saved')
    end
  end

  def allowed_params
    raise NoMethodError, "#{__method__} not implemented in #{self.class}"
  end

  def template_params
    params.require(:cms_template).permit(*allowed_params)
  end

  def templates
    current_account.templates
  end
end
