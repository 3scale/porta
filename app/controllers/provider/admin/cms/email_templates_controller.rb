class Provider::Admin::CMS::EmailTemplatesController < Sites::BaseController

  activate_menu :audience, :messages, :templates
  sublayout 'emails'

  def new
    @page = templates.new_by_system_name(params[:system_name])
  end

  def index
    @defaults = templates.all_new_and_overridden
  end

  def edit
    @page = templates.find(params[:id])
  end

  def update
    @page = templates.find(params[:id])

    if @page.update_attributes(params[:cms_template])
      flash[:info] = 'Email Template updated.'
      redirect_to action: :index
    else
      render :edit
    end
  end

  def create
    @page ||= templates.build(params[:cms_template])

    if @page.save
      flash[:info] = 'Email Template overrided.'
      redirect_to action: :index
    else
      render :new
    end
  end

  private

  def templates
    current_account.email_templates
  end

end
