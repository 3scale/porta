module EmailSupport
  def find_latest_email(options)
    deliveries = ActionMailer::Base.deliveries

    if options[:to]
      deliveries = deliveries.select do |email|
        email.to && email.to.include?(options[:to])
      end
    end

    deliveries.last
  end
end

World(EmailSupport)

Before '@emails' do
  ActionMailer::Base.deliveries.clear
  ActiveJob::Base.queue_adapter = :inline
end

After '@emails' do
  ActiveJob::Base.queue_adapter = Rails.configuration.active_job.queue_adapter
end
