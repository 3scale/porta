class ReverseProviderKeyWorker
  include Sidekiq::Worker

  # @param [Account,Provider] provider
  def self.enqueue(provider)
    perform_async(provider.id)
  end

  def perform(provider_id)
    provider = Provider.find(provider_id)

    app = provider.bought_cinstance

    # TODO: yes, I know it is security through obscurity,
    # but it allows to recover the key easily
    app.user_key = app.user_key.reverse
    app.save!
  end
end
