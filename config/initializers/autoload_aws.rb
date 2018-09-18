# Needed to fix https://github.com/3scale/system/issues/7661

Aws.eager_autoload!(services: %w(S3)) if Rails.application.config.eager_load && defined?(Aws)
