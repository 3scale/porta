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
    @feature ||= features.find(params[:feature_id] || params[:id])
  end

  def issuer_feature
    @issuer_feature ||= plan.issuer.features.find(params[:feature_id] || params[:id])
  end

  def feature_params
    { feature: issuer_feature }
  end

end
