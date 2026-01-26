# frozen_string_literal: true

require 'three_scale/middleware/developer_portal_permissions_policy'

module DeveloperPortal
  class Engine < ::Rails::Engine
    isolate_namespace DeveloperPortal

    config.autoload_paths += %W(#{config.root.join('lib')})
    config.paths.add 'lib', eager_load: true

    # Apply Developer Portal specific Permissions-Policy
    config.middleware.use ThreeScale::Middleware::DeveloperPortalPermissionsPolicy

    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w{ stats.css }
      Rails.application.config.assets.precompile += %w{ stats.js }
      Rails.application.config.assets.paths << root.join("app", "assets", "stylesheets")
      Rails.application.config.assets.paths << root.join("app", "assets", "javascripts")
    end
  end
end
