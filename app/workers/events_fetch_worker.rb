# frozen_string_literal: true

class EventsFetchWorker
  include Sidekiq::Worker

  sidekiq_options queue: :events

  def self.clear
    events_fetch_worker_selector = ->(job) { job.klass == 'EventFetchWorker' }
    jobs  = Sidekiq::RetrySet.new.select(&events_fetch_worker_selector)
    jobs += Sidekiq::ScheduledSet.new.select(&events_fetch_worker_selector)
    jobs << Sidekiq::Queue.new(:events)
    jobs.each(&:clear)
  end

  def self.enqueue
    clear
    perform_async
  end

  def perform
    Events.fetch_backend_events!
  end
end
