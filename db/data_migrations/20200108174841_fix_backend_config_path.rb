# frozen_string_literal: true

require 'progress_counter'

class FixBackendConfigPath < ActiveRecord::DataMigration
  def up
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
