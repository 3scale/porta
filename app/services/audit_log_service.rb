# frozen_string_literal: true

class AuditLogService
  include Callable

  def call(message)
    Rails.logger.info "[AUDIT]: #{message}"
  end
end

