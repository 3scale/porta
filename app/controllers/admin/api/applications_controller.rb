class Admin::Api::ApplicationsController < Admin::Api::BaseController
  representer ::Cinstance

  paginate only: :index

  # Application List (all services)
  # GET /admin/api/applications.xml
  def index
    apps = applications.scope_search(search)
           .serialization_preloading(request.format).paginate(:page => current_page, :per_page => per_page)
    respond_with(apps)
  end

  # Application Find
  # GET /admin/api/applications/find.xml
  def find
    respond_with(application)
  end

  private

  def application_filter_params
    params.permit(:active_since, :inactive_since)
  end

  def applications
    @applications ||= current_account.provided_cinstances.merge(accessible_services)
  end

  def application
    return @application if defined?(@application)

    scope = params[:service_id] ? applications.where(service_id: params[:service_id]) : applications

    @application = case

                     when param_key = params[:user_key]
      # TODO: these scopes should be in model layer
      # but there is scope named by_user_key already
      scope.where.has { (service.backend_version == '1') & (user_key == param_key) }.first!

                   when app_id = params[:app_id]
      scope.where.has { (service.backend_version != '1') & (application_id == app_id) }.first!

                     else
      scope.find(params[:application_id] || params[:id])
    end
  end

end
