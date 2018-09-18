require 'sidekiq/testing'

Before '@audit' do
  Audited.audit_class.audited_class_names.each { | cn | cn.constantize.enable_auditing }
end

After '@audit' do
  Audited.audit_class.audited_class_names.each { | cn | cn.constantize.disable_auditing }
end

Around '@audit' do |scenario, block|
  Sidekiq::Testing.inline!(&block)
end

AfterStep '@audit' do
  AuditedWorker.drain
end
