class Admin::Api::ApplicationsController < Admin::Api::BaseController
  representer ::Cinstance

  paginate only: :index

  # Application List (all services)
  # GET /admin/api/applications.xml
  def index
    apps = applications.scope_search(search)
           .serialization_preloading.paginate(:page => current_page, :per_page => per_page)
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

  def applications(services_association: Service.unscoped)
    @applications ||= Cinstance.provided_by(current_account, services_association: services_association.merge(accessible_services))
  end

  def application
    @application ||= case

                     when user_key = params[:user_key]
      # TODO: these scopes should be in model layer
      # but there is scope named by_user_key already
      applications(services_association: Service.unscoped.where(backend_version: '1')).where(user_key: user_key).first!

                     when app_id = params[:app_id]
      applications(services_association: Service.unscoped.where.not(backend_version: '1')).where(application_id: app_id).first!

                     else
      applications.find(params[:application_id] || params[:id])
    end
  end

end
