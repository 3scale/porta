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

Before do
  Sidekiq::Worker.clear_all
  ActionMailer::Base.deliveries.clear
end
