# frozen_string_literal: true

namespace :access_tokens do
  desc 'Enqueues a job to restore APIcast master access token from the environment'
  task :restore_master_apicast => :environment do
    RestoreApicastMasterTokenWorker.perform_later
  end
end
