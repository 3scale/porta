class Admin::Api::AccountFeaturesController < Admin::Api::BaseController
  wrap_parameters Feature
  representer Feature

  # Account Features List
  # GET /admin/api/features.xml
  def index
    respond_with(features)
  end

  # Account Feature Create
  # POST /admin/api/features.xml
  def create
    feature = features.create(feature_params)

    respond_with(feature)
  end

  # Account Feature Read
  # GET /admin/api/features/{id}.xml
  def show
    respond_with(feature)
  end

  # Account Feature Update
  # PUT /admin/api/features/{id}.xml
  def update
    feature.update(feature_params)

    respond_with(feature)
  end

  # Account Feature Delete
  # DELETE /admin/api/features/{id}.xml
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
