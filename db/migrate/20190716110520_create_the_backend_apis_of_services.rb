class CreateTheBackendApisOfServices < ActiveRecord::Migration
  def change
    say_with_time 'Migrating proxies api_backend to slugs...' do
      reversible do |dir|
        dir.up do
          Service.transaction do
            Service.find_each do |service|
              service.find_or_create_first_backend_api!
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
