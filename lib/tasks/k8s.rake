# frozen_string_literal: true

namespace :k8s do
  desc <<-DESC
  Restore missing objects:
   - create default proxies
   - TODO: Restore Master APIcast access token from the environment variables
  DESC
  task :deploy => %w[services:create_default_proxy access_tokens:restore_master_apicast]
end
