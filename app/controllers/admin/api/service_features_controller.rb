class Admin::Api::ServiceFeaturesController < Admin::Api::ServiceBaseController
  wrap_parameters Feature
  representer Feature

  # Service Feature List
  # GET /admin/api/services/{service_id}/features.xml
  def index
    respond_with(features)
  end

  # FIXME: scope?
  # Service Feature Create
  # POST /admin/api/services/{service_id}/features.xml
  def create
    feature = features.create(feature_params)

    respond_with(feature)
  end

  # Service Feature Read
  # GET /admin/api/services/{service_id}/features/{id}.xml
  def show
    respond_with(feature)
  end

  # Service Feature Update
  # PUT /admin/api/services/{service_id}/features/{id}.xml
  def update
    feature.update(feature_update_params)

    respond_with(feature)
  end

  # Service Feature Delete
  # DELETE /admin/api/services/{service_id}/features/{id}.xml
  def destroy
    feature.destroy

    respond_with(feature)
  end

  protected

  def feature_params
    params.require(:feature).permit(:name, :system_name, :description, :scope)
  end

  def feature_update_params
    feature_params.except(:scope)
  end

  def features
    @features ||= service.features
  end

  def feature
    @feature ||= features.find(params[:id])
  end
end
