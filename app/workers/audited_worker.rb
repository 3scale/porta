class AuditedWorker
  include Sidekiq::Job

  def perform(attributes)
    audit = Audited.audit_class.new
    audit.assign_attributes(attributes, without_protection: true) # Rails 4 can remove the option
    audit.save!
  end
end
