# frozen_string_literal: true

Rails.configuration.three_scale.features.each_key do |feature_name|
  feature = "Features::#{feature_name.to_s.camelize}Config".constantize
  feature.configure Rails.configuration.three_scale.features.public_send(feature_name)
end
