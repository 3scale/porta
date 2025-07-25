class Provider::Admin::CMS::EmailTemplatesController < Sites::BaseController

  activate_menu :audience, :messages, :templates

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

    if @page.update(cms_templates_params)
      redirect_to({ action: :index }, success: t('.success'))
    else
      render :edit
    end
  end

  def create
    @page ||= templates.build(cms_templates_params)

    if @page.save
      redirect_to({ action: :index }, success: t('.success'))
    else
      render :new
    end
  end

  private

  def templates
    current_account.email_templates
  end

  def cms_templates_params
    params.require(:cms_template).permit(:system_name, :draft, headers: %i[subject bcc cc reply_to from])
  end

end
