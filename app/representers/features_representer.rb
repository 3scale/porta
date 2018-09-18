module FeaturesRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :features

  items extend: FeatureRepresenter
end
