# frozen_string_literal: true

require 'three_scale/metrics/yabeda'

Rails.application.config.after_initialize do
  ThreeScale::Metrics::Yabeda.install!
end
