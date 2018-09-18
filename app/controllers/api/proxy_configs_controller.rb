class Api::ProxyConfigsController < Api::BaseController
  load_and_authorize_resource :service, through: :current_user, through_association: :accessible_services

  activate_menu :main_menu => :serviceadmin, :sidebar => :integration
  sublayout 'api/service'

  def index
    if params[:environment].to_s.downcase == 'production'.freeze
      @proxy_configs    = proxy_configs.production.paginate(paginate_params)
      @environment_name = 'Production'.freeze
    else
      @proxy_configs    = proxy_configs.sandbox.paginate(paginate_params)
      @environment_name = 'Staging'.freeze
    end
  end

  def show
    config = proxy_config

    if stale?(config)
      send_data config.content,
                type: config.content_type,
                disposition: 'attachment',
                filename: config.filename
    end
  end

  protected

  attr_reader :service

  def proxy_configs
    service.proxy.proxy_configs.newest_first
  end

  def proxy_config
    proxy_configs.find(params[:id])
  end

  def paginate_params
    { page: params[:page] || 1, per_page: 20 }
  end

end
