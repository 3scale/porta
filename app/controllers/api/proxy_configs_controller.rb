# frozen_string_literal: true

class Api::ProxyConfigsController < Api::BaseController
  load_and_authorize_resource :service, through: :current_user, through_association: :accessible_services

  activate_menu :serviceadmin, :integration, :configuration

  def index
    configs = params[:environment].to_s.casecmp?('production') ? proxy_configs.production : proxy_configs.sandbox
    @proxy_configs = configs.paginate(paginate_params).decorate
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
