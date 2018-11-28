# frozen_string_literal: true

class SuspendInactiveAccountsWorker
  include Sidekiq::Worker

  def perform
    Account.tenants.inactive_since.find_each(&:suspend!)
  end
end
