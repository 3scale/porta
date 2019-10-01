# frozen_string_literal: true

require 'progress_counter'

class CreateTheBackendApisOfServices < ActiveRecord::Migration
  def change
    return puts "Nothing to do, this migration should not be executed" # Moved to lib/tasks/services.rake:create_backend_apis

    say_with_time 'Migrating proxies api_backend to slugs...' do
      reversible do |dir|
        dir.up do
          Service.transaction do
            progress = ProgressCounter.new(Service.count)
            Service.find_each(batch_size: 100) do |service|
              progress.call do
                service.find_or_create_first_backend_api!
              end
            end
          end
        end

        dir.down do
          BackendApi.transaction do
            BackendApiConfig.delete_all
            BackendApi.delete_all
          end
        end
      end
    end
  end
end
