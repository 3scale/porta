class HerokuWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  def self.sync(provider_id)
    perform_async(provider_id)
  end

  def perform(provider_id)
    provider = Account.providers.find(provider_id)
    Heroku.sync(provider)
  end
end
