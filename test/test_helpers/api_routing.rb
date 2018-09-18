# frozen_string_literal: true

module ApiRouting
  class FooApiController < ::Admin::Api::BaseController
    wrap_parameters :payload

    def index
      render json: {status: :success}
    end

    def create
      render json: {status: :success, name: payload_params[:name], body: payload_params[:body]}
    end

    def show
      respond_to do |format|
        format.json { render json: {version: params[:version]}}
      end
    end

    protected

    def payload_params
      params.require(:payload).permit(:body, :name)
    end
  end

  class CMSApiController < ::Admin::Api::CMS::BaseController
    def index
      render json: {status: :success}
    end
  end

  protected

  def with_api_routes
    Rails.application.routes.draw do
      constraints MasterOrProviderDomainConstraint do
        post '/api' => 'api_routing/foo_api#create'
        get '/api' => 'api_routing/foo_api#index'
        get '/api/version/:version' => 'api_routing/foo_api#show'
      end


      get '/cms_api' => 'api_routing/cms_api#index'

    end
    yield
  ensure
    Rails.application.routes_reloader.reload!
  end
end
