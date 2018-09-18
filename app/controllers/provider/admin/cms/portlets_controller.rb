class Provider::Admin::CMS::PortletsController < Provider::Admin::CMS::TemplatesController
  before_action :pick_portlet_type, :only => :new

  def create
    @page ||= templates.build(template_params).to_portlet

    super
  end

  def update
    @page ||= templates.find(params[:id]).to_portlet

    super
  end

  def edit
    @page ||= templates.find(params[:id]).to_portlet
    super
  end

  def new
    @page = templates.new(portlet_type: params[:type]).to_portlet

    super
  end

  def pick
    @available_portlets = CMS::Portlet.available
  end

  private

  def pick_portlet_type
    redirect_to :action => :pick unless params[:type]
  end

  def templates
    current_account.portlets
  end

  def template_params
    params.require(:cms_template).permit(:title, :portlet_type, :system_name,
      :draft, :url_feed, :type)
  end

end
