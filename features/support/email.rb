# frozen_string_literal: true

module EmailSupport
  def find_latest_email(options)
    deliveries = ActionMailer::Base.deliveries

    if (options_to = options[:to])
      deliveries = deliveries.select do |email|
        email.to&.include?(options_to)
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
