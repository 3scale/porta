require_dependency 'notification_center'

class SignupWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  def self.enqueue(provider)
    perform_async(provider.id)
  end

  def perform(provider_id)
    batch = Sidekiq::Batch.new
    batch.description = "Provider Signup (id: #{provider_id})"

    batch.jobs do
      SampleDataWorker.perform_async(provider_id)
      ImportSimpleLayoutWorker.perform_async(provider_id)
    end
  end

  class SampleDataWorker
    include Sidekiq::Worker
    sidekiq_options queue: :critical

    def perform(provider_id)
      provider = ::Account.providers.find(provider_id)

      return unless provider.sample_data?

      ::NotificationCenter.silent_about(::Cinstance, ::Contract, ::ApiDocs::Service,
                                        ::BaseEventStoreEvent) do
        provider.create_sample_data!
      end

      provider.update_column(:sample_data, false)
    end
  end

  class ImportSimpleLayoutWorker
    include Sidekiq::Worker
    sidekiq_options queue: :critical

    def perform(provider_id)
      provider = ::Account.providers.find(provider_id)
      provider.import_simple_layout!
    end
  end
end
