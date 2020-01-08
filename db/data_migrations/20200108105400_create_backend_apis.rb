# frozen_string_literal: true

require 'progress_counter'

class CreateBackendApis < ActiveRecord::DataMigration
  def up
    services = Service.where.has { not_exists(BackendApiConfig.except(:order).select(:id).by_service(BabySqueel[:services].id)) }

    return puts 'Nothing to do.' if services.empty?

    progress = ProgressCounter.new(services.count)

    services.includes(:backend_api_configs).find_each(batch_size: 100) do |service|
      progress.call do
        next if service.backend_api_configs.any?

        service_name = service.name
        backend_api = service.account.backend_apis.create(
          system_name: service.system_name,
          name: "#{service_name} Backend",
          description: "Backend of #{service_name}",
          private_endpoint: service.proxy&.[]('api_backend')
        )

        service.backend_api_configs.create(backend_api: backend_api, path: '/')
      end
    end
  end
end
