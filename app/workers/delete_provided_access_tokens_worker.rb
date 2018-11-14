# frozen_string_literal: true

class DeleteProvidedAccessTokensWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform
    ProvidedAccessToken.long_expired.delete_all
  end
end
