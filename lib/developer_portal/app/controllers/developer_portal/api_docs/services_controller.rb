class DeveloperPortal::ApiDocs::ServicesController < DeveloperPortal::BaseController
  before_action :disable_x_content_type
  skip_before_action :login_required
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  def index
    respond_to do |format|
      format.json do
        render json: ::ApiDocs::Service.for(site_account), callback: params[:callback]
      end
    end
  end

  def show
    body = site_account.api_docs_services.find(params[:id]).body

    respond_to do |format|
      format.json { render json: body, callback: params[:callback] }
    end
  end
end
