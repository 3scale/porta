class AuditedWorker
  include Sidekiq::Worker

  def perform(attributes)
    audit = Audited.audit_class.new
    audit.synchronous = true
    audit.assign_attributes(attributes, without_protection: true) # Rails 4 can remove the option
    audit.save!
  end
end
