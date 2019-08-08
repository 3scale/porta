class Api::ProxyRulesController < Api::BaseController
  include ThreeScale::Search::Helpers

  before_action :authorize!, :find_service, :find_proxy
  before_action :find_proxy_rule, only: %i[edit update destroy]

  activate_menu :serviceadmin, :integration, :mapping_rules

  sublayout 'api/service'

  def index
    @proxy_rules = @proxy.proxy_rules.order_by(params[:sort], params[:direction])
                                     .includes(:metric).ordered.paginate(page: params[:page])
  end

  def new
    last_position = @proxy.proxy_rules.maximum(:position) || 0
    next_position = last_position + 1
    @proxy_rule = @proxy.proxy_rules.build(position: next_position, delta: 1)
  end

  def create
    @proxy_rule = @proxy.proxy_rules.build(proxy_rule_params)
    if @proxy_rule.save
      redirect_to admin_service_proxy_rules_path(@service), notice: 'Mapping rule was created.'
    else
      render :new
    end
  end

  def update
    if @proxy_rule.update_attributes(proxy_rule_params)
      redirect_to admin_service_proxy_rules_path(@service), notice: 'Mapping rule was updated.'
    else
      render :edit
    end
  end

  def destroy
    if @proxy_rule.destroy
      flash[:notice] = 'The mapping rule was deleted'
    else
      flash[:error] = 'The mapping rule cannot be deleted'
    end

    redirect_to admin_service_proxy_rules_path(@service)
  end

  private

  def authorize!
    provider_can_use!(:independent_mapping_rules)
  end

  def find_proxy
    @proxy = @service.proxy
  end

  def find_proxy_rule
    @proxy_rule = @proxy.proxy_rules.find(params[:id])
  end

  def find_service
    @service = current_user.accessible_services.find(params[:service_id])
  end

  def proxy_rule_params
    params.require(:proxy_rule).permit(%i[http_method pattern delta metric_id position last redirect_url])
  end
end
