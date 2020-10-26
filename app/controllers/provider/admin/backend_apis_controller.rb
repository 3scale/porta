# frozen_string_literal: true

class Provider::Admin::BackendApisController < Provider::Admin::BaseController
  include SearchSupport
  include ThreeScale::Search::Helpers

  load_and_authorize_resource :backend_api, through: :current_user, through_association: :accessible_backend_apis

  activate_menu :backend_api, :overview
  layout 'provider'

  def index
    activate_menu :backend_apis
    search = ThreeScale::Search.new(params[:search] || params)
    @raw_backend_apis = current_account.backend_apis
    @backend_apis = @raw_backend_apis.order(updated_at: :desc)
                                     .paginate(pagination_params)
                                     .scope_search(search)
                                     .decorate
                                     .to_json(only: %i[name updated_at id private_endpoint system_name], methods: %i[links products_count])
  end

  def new
    activate_menu :backend_apis
  end

  def create
    if @backend_api.save
      redirect_to provider_admin_backend_api_path(@backend_api), notice: 'Backend created'
    else
      flash.now[:error] = 'Backend could not be created'
      activate_menu :backend_apis
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @backend_api.update_attributes(update_params)
      redirect_to provider_admin_backend_api_path(@backend_api), notice: 'Backend updated'
    else
      flash.now[:error] = 'Backend could not be updated'
      render :edit
    end
  end

  def destroy
    if @backend_api.mark_as_deleted
      redirect_to provider_admin_dashboard_path, notice: 'Backend will be deleted shortly.'
    else
      flash[:error] = @backend_api.errors.full_messages.to_sentence
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
end
