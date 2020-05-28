# frozen_string_literal: true

# Silence our custom deprecator in test, production and preview
# Stop to spam
ThreeScale::Deprecation.silenced = %w[test production preview].include?(Rails.env)
