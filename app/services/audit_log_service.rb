# frozen_string_literal: true

class AuditLogService

  def log(message)
    Rails.logger.info "[AUDIT]: #{message}"
  end
end
