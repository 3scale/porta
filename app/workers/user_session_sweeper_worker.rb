# frozen_string_literal: true

class UserSessionSweeperWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform(id)
    UserSession.destroy(id)
  end
end
