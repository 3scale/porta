# frozen_string_literal: true

# The production image serves precompiled assets and excludes the assets group.
if defined?(Dartsass::Engine)
  Rails.application.config.dartsass.builds = {
    '.' => '.',
    '../../../lib/developer_portal/app/assets/stylesheets' => '.',
    'provider/stats/_base.scss' => 'provider/stats/base.css',
    'provider/stats/_selector.scss' => 'provider/stats/selector.css',
    '../../../vendor/active-docs/app/assets/stylesheets/active-docs/application.scss' => 'active-docs/application.css'
  }

  # Keep the legacy SCSS import order and syntax on the 2.16 branch.
  Rails.application.config.dartsass.build_options << '--silence-deprecation=import,slash-div,global-builtin,color-functions'
end
