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

  def accessible_service_ids
    @accessible_service_ids ||= accessible_services.select(:id)
  end

  def applications
    # Use a subquery instead of a JOIN to enable the CTE-based paginator
    # optimization, see WillPaginateMysqlOptimizedLookup.
    @applications ||= Cinstance.where(service_id: accessible_service_ids)
  end

  def application
    return @application if defined?(@application)

    svc_ids = accessible_service_ids
    svc_ids = svc_ids.where(id: params[:service_id]) if params[:service_id]

    @application = case
                     when param_key = params[:user_key]
      Cinstance.where(service_id: svc_ids.where(backend_version: '1'), user_key: param_key).first!

                   when app_id = params[:app_id]
      Cinstance.where(service_id: svc_ids.where.not(backend_version: '1')).where(application_id: app_id).first!

                     else
      Cinstance.where(service_id: svc_ids).find(params[:application_id] || params[:id])
    end
  end

end
