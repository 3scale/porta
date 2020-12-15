# frozen_string_literal: true

class Api::PoliciesController < Api::BaseController
  before_action :check_permission
  before_action :find_resources

  activate_menu :serviceadmin, :integration, :policies

  sublayout 'api/service'

  def edit
    render status: status_from_error(:ok)
  end

  def update
    if proxy.update(proxy_params)
      redirect_to({action: :edit}, notice: 'The policies are saved successfully')
    else
      flash.now[:error] = 'The policies cannot be saved'
      render :edit, status: status_from_error(:unprocessable_entity)
    end
  end

  protected

  def proxy_params
    params.require(:proxy).permit(:policies_config)
  end

  def check_permission
    authorize! :edit, service
    raise Cancan::AccessDenied unless service.can_use_policies?
  end

  def proxy
    @proxy ||= service.proxy
  end

  def service
    @service ||= current_user.accessible_services.find(params[:service_id])
  end

  def find_resources
    policies_list = Policies::PoliciesListService.call!(current_account, proxy: proxy)
    @registry_policies = PoliciesListPresenter.new(policies_list).registry
  rescue StandardError => error
    @error = error
  end

  def status_from_error(alternate)
    server_error? ? :service_unavailable : alternate
  end

  def server_error?
    @error.present?
  end
end
