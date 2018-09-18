class Admin::Api::ServiceFeaturesController < Admin::Api::ServiceBaseController
  wrap_parameters Feature
  representer Feature

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/features.xml"
  ##~ e.responseClass = "List[feature]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Service Feature List"
  ##~ op.description = "Returns the list of all features of a service."
  ##~ op.group = "service_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  #
  def index
    respond_with(features)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/features.xml"
  ##~ e.responseClass = "feature"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Service Feature Create"
  ##~ op.description = "Creates a feature on a service. Features are usually associated to a particular type of plan; you can associate the plan on the scope parameter. Note that account plans are not scoped by service."
  ##~ op.group = "service_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add :name => "name", :description => "Name of the feature.", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add @parameter_system_name_by_name
  ##~ op.parameters.add :name => "description", :description => "Description of the feature.", :dataType => "text", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "scope", :description => "Type of plan that the feature will be available for.", :dataType => "string", :allowMultiple => true, :required => false, :paramType => "query", :defaultValue => "ApplicationPlan", :allowableValues => {:values => ["ApplicationPlan","ServicePlan"], :valueType => "LIST"}
  # FIXME: scope?
  #
  def create
    feature = features.create(feature_params)

    respond_with(feature)
  end


  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/features/{id}.xml"
  ##~ e.responseClass = "feature"
  #
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Service Feature Read"
  ##~ op.description = "Returns a feature of a service."
  ##~ op.group = "service_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_feature_id_by_id
  #
  def show
    respond_with(feature)
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Service Feature Update"
  ##~ op.description = "Updates a feature of a service."
  ##~ op.group = "service_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_feature_id_by_id
  ##~ op.parameters.add :name => "name", :description => "Name of the feature.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the feature.", :dataType => "text", :allowMultiple => false, :required => false, :paramType => "query"
  #
  def update
    feature.update_attributes(feature_params)

    respond_with(feature)
  end


  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Service Feature Delete"
  ##~ op.description = "Deletes a feature of a service."
  ##~ op.group = "service_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_feature_id_by_id
  #
  def destroy
    feature.destroy

    respond_with(feature)
  end

  protected

  def feature_params
    params.fetch(:feature)
  end

  def features
    @features ||= service.features
  end

  def feature
    @feature ||= features.find(params[:id])
  end
end
