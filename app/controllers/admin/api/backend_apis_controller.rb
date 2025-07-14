# frozen_string_literal: true

class Admin::Api::BackendApisController < Admin::Api::BaseController
  self.access_token_scopes = :account_management

  before_action :authorize

  clear_respond_to
  respond_to :json

  wrap_parameters BackendApi, include: BackendApi.attribute_names | %w[annotations]
  representer BackendApi

  paginate only: :index

  # Backend List
  # GET /admin/api/backend_apis.json
  def index
    respond_with(current_account.backend_apis.accessible.oldest_first.paginate(pagination_params))
  end

  # Backend Create
  # POST /admin/api/backend_apis.json
  def create
    backend_api = current_account.backend_apis.create(create_params)
    respond_with(backend_api)
  end

  # Backend Read
  # GET /admin/api/backend_apis/{id}.json
  def show
    respond_with(backend_api)
  end

  # Backend Update
  # PUT /admin/api/backend_apis/{id}.json
  def update
    backend_api.update(update_params)
    respond_with(backend_api)
  end

  # Backend Delete
  # DELETE /admin/api/backend_apis/{id}.json
  def destroy
    backend_api.mark_as_deleted
    respond_with(backend_api)
  end

  private

  DEFAULT_PARAMS = [:name, :description, :private_endpoint, {annotations: {}}].freeze
  private_constant :DEFAULT_PARAMS

  def authorize
    return unless current_user # provider_key access
    authorize! action_name.to_sym, BackendApi
  end

  def backend_api
    @backend_api ||= current_account.backend_apis.accessible.find(params[:id])
  end

  def create_params
    params.require(:backend_api).permit(DEFAULT_PARAMS | %i[system_name])
  end

  def update_params
    params.require(:backend_api).permit(DEFAULT_PARAMS)
  end
end
