# frozen_string_literal: true

class SuspendInactiveProvidersWorker
  include Sidekiq::Job

  PLANS = [
    2357355454121, # 2013 Enterprise (Trial)
    2357355852196, # 90 Day Trial (50K calls/day)
    2357355916595, # Enterprise (Eval)
    2357355814696, # Developer
    2357355852194, # Personal (5K calls/day)
  ].freeze

  def scope
    Account.providers
           .includes(:bought_cinstances)
           .where(state: 'approved')
           .where(bought_cinstances: { first_daily_traffic_at: ..6.months.ago })
           .where(bought_cinstances: { plan_id: PLANS })
  end

  def perform
    scope.find_in_batches do |providers|
      provider_ids = providers.pluck(:id)
      enqueue_providers_in_batch(provider_ids)
    end
  end

  def enqueue_providers_in_batch(provider_ids)
    batch = Sidekiq::Batch.new
    batch.description = "Suspend inactive providers: #{provider_ids}"

    batch.jobs do
      provider_ids.each do |provider_id|
        SuspendProviderWorker.perform_async(provider_id)
      end
    end
  end

  class SuspendProviderWorker
    include Sidekiq::Job

    sidekiq_options queue: :low

    def perform(provider_id)
      Account.providers.find(provider_id).suspend!
    end
  end
end
