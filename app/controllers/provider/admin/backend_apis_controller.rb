# frozen_string_literal: true

class Provider::Admin::BackendApisController < Provider::Admin::BaseController
  include SearchSupport
  include ThreeScale::Search::Helpers

  load_and_authorize_resource :backend_api, through: :current_user, through_association: :accessible_backend_apis

  activate_menu :backend_api, :overview
  layout 'provider'

  helper_method :presenter

  def index
    activate_menu :backend_apis
  end

  def new
    activate_menu :backend_apis
  end

  def create
    activate_menu :backend_apis
    respond_to do |format|
      if @backend_api.save
        format.json { render json: @backend_api.decorate.add_backend_usage_backends_data, status: :created }
        format.html { redirect_to provider_admin_backend_api_path(@backend_api), success: t('.success') }
      else
        flash.now[:danger] = t('.error')
        format.json { render json: @backend_api.errors, status: :unprocessable_entity }
        format.html { render :new }
      end
    end
  end

  def show; end

  def edit; end

  def update
    if @backend_api.update(update_params)
      redirect_to provider_admin_backend_api_path(@backend_api), success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render :edit
    end
  end

  def destroy
    if @backend_api.mark_as_deleted
      redirect_to provider_admin_dashboard_path, success: t('.success')
    else
      flash[:danger] = @backend_api.errors.full_messages.to_sentence
      render :edit
    end
  end

  protected

  DEFAULT_PARAMS = %i[name description private_endpoint].freeze
  private_constant :DEFAULT_PARAMS

  def backend_api_params(*extra_params)
    params.require(:backend_api).permit(DEFAULT_PARAMS | extra_params)
  end

  def create_params
    backend_api_params(:system_name)
  end

  alias update_params backend_api_params

  def presenter
    @presenter ||= Provider::Admin::BackendApisIndexPresenter.new(user: current_user, params: params)
  end
end
