# frozen_string_literal: true

require 'three_scale/metrics/yabeda'

Rails.application.config.to_prepare do
  ThreeScale::Metrics::Yabeda.install!
end
