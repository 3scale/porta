# frozen_string_literal: true

class Admin::Api::BackendApisController < Admin::Api::BaseController
  self.access_token_scopes = :account_management

  # TODO: ApiDocs documentation

  before_action :find_backend_api, only: %i[show update destroy]
  before_action :authorize

  clear_respond_to
  respond_to :json

  representer ::BackendApi

  paginate only: :index

  def index
    respond_with(current_account.backend_apis.paginate(pagination_params))
  end

  def create
    backend_api = current_account.backend_apis.create(backend_api_params)
    respond_with(backend_api)
  end

  def show
    respond_with(backend_api)
  end

  def update
    backend_api.update(backend_api_params)
    respond_with(backend_api)
  end

  def destroy
    backend_api.destroy
    respond_with(backend_api)
  end

  private

  attr_reader :backend_api

  def authorize
    provider_can_use!(:api_as_product)
    # TODO: I guess it should authorize also that it has permission for the specific action :)
  end

  def find_backend_api
    @backend_api = current_account.backend_apis.find(params[:id])
  end

  def backend_api_params
    # Not sure about :system_name but for Service it is readonly # TODO ?
    params.require(:backend_api).permit(:name, :description, :private_endpoint)
  end
end
