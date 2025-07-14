if (Rails.env.development? || Rails.env.test?) && ENV["TRACE_SQL"] == "1"
  ActiveRecordQueryTrace.enabled = true
  ActiveRecordQueryTrace.level = :app
  Rails.application.config.log_level = :debug
end
