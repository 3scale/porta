class Admin::Api::AccountFeaturesController < Admin::Api::BaseController
  wrap_parameters Feature
  representer Feature

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/features.xml"
  ##~ e.responseClass = "List[feature]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Account Features List"
  ##~ op.description = "Returns the list of the features available to accounts. Account features are globally scoped."
  ##~ op.group = "account_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def index
    respond_with(features)
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary   = "Account Feature Create"
  ##~ op.description = "Create an account feature. The features of the account are globally scoped. Creating a feature does not associate the feature with an account plan."
  ##~ op.group = "account_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "name", :description => "Name of the feature.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add @parameter_system_name_by_name
  #
  def create
    feature = features.create(feature_params)

    respond_with(feature)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/features/{id}.xml"
  ##~ e.responseClass = "feature"
  ##~ e.description   = "Returns an account feature."
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Account Feature Read"
  ##~ op.description = "Returns an account feature."
  ##~ op.group = "account_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_feature_id_by_id
  #
  def show
    respond_with(feature)
  end


  # swagger
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary   = "Account Feature Update"
  ##~ op.description = "Updates an account feature."
  ##~ op.group = "account_feature"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_feature_id_by_id
  ##~ op.parameters.add :name => "name", :description => "Name of the feature.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  #
  def update
    feature.update_attributes(feature_params)

    respond_with(feature)
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Account Feature Delete"
  ##~ op.description = "Deletes an account feature."
  ##~ op.group = "account_feature"
  #
  ##~ op.parameters.add @parameter_access_token
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
    @features ||= current_account.features
  end

  def feature
    @feature ||= features.find(params[:id])
  end
end
