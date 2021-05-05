# frozen_string_literal: true

class CreateDefaultProxyWorker < ApplicationJob

  rescue_from(ActiveJob::DeserializationError, ActiveRecord::RecordNotFound) do |exception|
    Rails.logger.info "#{self.class}#perform raised #{exception.class} with message #{exception.message}"
  end

  # :reek:UtilityFunction
  def perform(service)
    service.create_default_proxy
  end

  class BatchEnqueueWorker < ApplicationJob

    # :reek:UtilityFunction
    def perform(*)
      Service.includes(:proxy).where(proxies: {service_id: nil}).find_each do |service|
        CreateDefaultProxyWorker.perform_later(service)
      end
    end
  end
end
