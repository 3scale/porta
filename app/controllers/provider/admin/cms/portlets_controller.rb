class Provider::Admin::CMS::PortletsController < Provider::Admin::CMS::TemplatesController
  before_action :pick_portlet_type, :only => :new

  def create
    template ||= templates.build
    template.portlet_type = template_params[:portlet_type]
    @page = template.to_portlet

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

  def allowed_params
    %i[title portlet_type system_name draft url_feed type section_id posts].freeze
  end

end
