module ActiveDocs
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w(
        add.png remove.png
        active-docs/application.js active-docs/application.css
      )
    end
  end
end
