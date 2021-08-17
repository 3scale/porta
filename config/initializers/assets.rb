# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.

# Rails.application.config.assets.precompile += %w( admin.js admin.css )
class AssetsOptionsResponder
  TYPES = %w(eot svg ttf otf woff woff2).freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    if env["REQUEST_METHOD"] == "OPTIONS" && targeted?(env["PATH_INFO"])
      [204, access_control_headers, []]
    else
      @app.call(env)
    end
  end

  private

  def targeted?(pathinfo)
    return if pathinfo.blank?
    TYPES.include? extension(pathinfo)
  end

  def extension(pathinfo)
    pathinfo.split("?").first.split(".").last
  end

  def access_control_headers
    Rails.configuration.public_file_server.headers
  end
end

Rails.application.configure do
  if Rails.configuration.public_file_server.enabled &&
      Rails.configuration.public_file_server.headers.include?("Access-Control-Allow-Origin")
    config.middleware.insert_before ActionDispatch::Static, AssetsOptionsResponder
  end
end
