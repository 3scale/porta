class AuditLogService
  include Callable

  def self.call(message)
    Rails.logger.info "[AUDIT]: #{message}"
  end
end