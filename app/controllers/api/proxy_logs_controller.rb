class Api::ProxyLogsController < Api::BaseController

  before_action :find_service
  before_action :authorize
  before_action :activate_submenu
  before_action :proxy_logs

  def index
    @proxy_logs = proxy_logs.paginate(paginate_params)
  end

  def show
    send_data find_proxy_log.lua_file,
              :type => 'text/plain',
              :disposition => 'attachment',
              :filename => find_proxy_log.file_name
  end

  protected

  def find_proxy_log
    @lua_content ||= @proxy_logs.find(params[:id])
  end

  def authorize
    authorize! :edit, @service
  end

  def proxy_logs
    @proxy_logs ||= current_account.proxy_logs.latest_first
  end

  def paginate_params
    { :page => params[:page] || 1, :per_page => 20 }
  end

end
