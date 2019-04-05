# frozen_string_literal: true

class StaleAccountWorker
  include Sidekiq::Worker

  def perform
    AutoAccountDeletionQueries.should_be_scheduled_for_deletion.find_each(&:schedule_for_deletion!)
  end
end
