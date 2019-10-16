# frozen_string_literal: true

namespace :data_migration do
  desc 'Backfill Paths for Backend Api Configs'
  task :fix_backend_config_path do
    query = System::Database.oracle? ? BackendApiConfig.where('path is NULL') : BackendApiConfig.where(path: '')
    progress = ProgressCounter.new(query.count)
    BackendApiConfig.transaction do
      query.select(:id).find_in_batches(batch_size: 200) do |records|
        BackendApiConfig.where(id: records.map(&:id)).update_all(path: '/')
        progress.call(increment: records.size)
      end
    end
  end
end
