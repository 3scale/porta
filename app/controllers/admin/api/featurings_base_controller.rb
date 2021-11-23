class Admin::Api::FeaturingsBaseController < Admin::Api::BaseController
  representer Feature

  def index
    respond_with(features)
  end

  def create
    #TODO: check what with already enabled feature
    feature_plan = features_plans.create(feature_params)

    respond_with(feature_plan, serialize: issuer_feature)
  end

  def destroy
    feat = features.delete(feature)

    respond_with(feat)
  end

  protected

  def features_plans
    @features_plans ||= plan.features_plans
  end

  def features
    @features ||= plan.features
  end

  def feature
    @feature ||= features.find(feature_id_params[:feature_id] || feature_id_params[:id])
  end

  def issuer_feature
    @issuer_feature ||= plan.issuer.features.find(feature_id_params[:feature_id] || feature_id_params[:id])
  end

  def feature_params
    { feature: issuer_feature }
  end

  def feature_id_params
    params.permit(:feature_id, :id).to_h
  end

end
