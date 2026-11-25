# frozen_string_literal: true

# The production image serves precompiled assets and excludes the assets group.
if defined?(NonDigestAssets)
  NonDigestAssets.asset_selectors += %w[
    provider/signup_v2.js
    ajax-loader.gif
    tree-line.png
    3scale-logo.png
    error.css
  ]
end
