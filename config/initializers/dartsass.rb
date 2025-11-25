Rails.application.config.dartsass.builds = {
  "." => ".",
  "../../../lib/developer_portal/app/assets/stylesheets" => "."
}

# Enable source maps for debugging in development
if Rails.env.development?
  # Override default --no-source-map
  Rails.application.config.dartsass.build_options = %w[--style=expanded --embed-sources --embed-source-map]
end
