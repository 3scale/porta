# frozen_string_literal: true

class Api::BackendUsagesController < Api::BaseController
  include ThreeScale::Search::Helpers

  load_and_authorize_resource :service, through: :current_user, through_association: :accessible_services

  before_action :authorize
  before_action :find_backend_api_config, only: %i[edit update destroy]
  before_action :ensure_same_account_backend_api, only: :create

  activate_menu :serviceadmin, :integration, :backend_api_configs
  sublayout 'api/service'

  helper_method :service, :toolbar_props

  def index
    @backend_api_configs = service.backend_api_configs.order_by(params[:sort], params[:direction])
                                                      .includes(:backend_api)
                                                      .paginate(pagination_params)
  end

  def new
    @backend_api_config = service.backend_api_configs.build
  end

  def create
    @backend_api_config = service.backend_api_configs.build(backend_api_config_params)

    if @backend_api_config.save
      flash[:notice] = 'Backend added to Product.'
      redirect_to admin_service_backend_usages_path(@service)
    else
      flash[:error] = "Couldn't add Backend to Product"
      @inline_errors = @backend_api_config.errors.as_json
      render 'new'
    end
  end

  def edit; end

  def update
    if @backend_api_config.update(backend_api_config_params.slice(:path))
      redirect_to admin_service_backend_usages_path(@service), notice: 'Backend usage was updated.'
    else
      render :edit
    end
  end

  def destroy
    if @backend_api_config.destroy
      flash[:notice] = 'The Backend was removed from the Product'
    else
      flash[:error] = 'The Backend cannot be removed from the Product'
    end

    redirect_to admin_service_backend_usages_path(@service)
  end

  protected

  def authorize
    authorize! :manage, BackendApiConfig
    raise Cancan::AccessDenied unless service.can_use_backends?
  end

  attr_reader :service

  delegate :backend_api_configs, to: :service

  def backend_api_config_params
    params.require(:backend_api_config).permit(:backend_api_id, :path)
  end

  def find_backend_api_config
    @backend_api_config = service.backend_api_configs.find(params[:id])
  end

  def ensure_same_account_backend_api
    return if current_account.backend_apis.find_by(id: backend_api_config_params[:backend_api_id])

    flash[:error] = "Couldn't add Backend to Product"
    @inline_errors = { backend_api_id: ['Not a valid backend'] }
    render 'new'
  end

  def toolbar_props
    {
      totalEntries: @backend_api_configs.total_entries,
      actions: [{
        variant: :primary,
        label: t('.toolbar.primary'),
        href: new_admin_service_backend_usage_path(@service),
      }]
    }
  end
end
