# frozen_string_literal: true

class SuspendInactiveAccountsWorker
  include Sidekiq::Worker

  def perform
    AutoAccountDeletionQueries.should_be_suspended.find_each(&:suspend!)
  end
end
