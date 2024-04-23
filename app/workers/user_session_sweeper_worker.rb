# frozen_string_literal: true

class UserSessionSweeperWorker
  include Sidekiq::Job
  sidekiq_options queue: :low

  def perform(id)
    UserSession.delete(id)
  end
end
