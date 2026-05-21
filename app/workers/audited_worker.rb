class AuditedWorker
  include Sidekiq::Job

  def perform(attributes)
    audit = Audited.audit_class.new
    audit.assign_attributes(attributes)
    audit.save!
  end
end
