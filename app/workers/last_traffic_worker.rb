require_dependency 'last_traffic'

class LastTrafficWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  delegate :logger, to: Rails

  def perform(provider_id, timestamp = Time.now)
    begin
      provider = Provider.find(provider_id)
    rescue ActiveRecord::RecordNotFound
      return # when provider was destroyed, just skip the job
    end

    traffic = LastTraffic.sent_traffic_on(provider, Time.at(timestamp))

    if traffic && traffic > 0
      logger.info "Provider #{provider_id} had #{traffic} hits"
    else
      logger.info "Provider #{provider_id} had no traffic"
    end
  end
end
