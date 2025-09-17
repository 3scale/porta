# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# We do not add to asset paths because or a webpacker compatibility
# https://github.com/rails/webpacker/issues/1285#issuecomment-539553734
# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
# Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.

# Rails.application.config.assets.precompile += %w( admin.js admin.css )

Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")

Rails.application.config.assets.precompile += %w[
  error.css
  login.css
  font-awesome.css
  provider/signup_v2.js
  provider/signup_form.js
  provider/layout/provider.js
]
