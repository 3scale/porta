# frozen_string_literal: true

class SuspendInactiveAccountsWorker
  include Sidekiq::Worker

  def perform
    Account.should_be_automatically_suspended.find_each(&:suspend!)
  end
end
