module UserTrackingHelper

  def analytics_identity_data
    traits = ThreeScale::Analytics.traits(current_user)
    session_analytics = analytics_session.traits

    traits.merge(session_analytics)
  end

end
