# frozen_string_literal: true

class SuspendInactiveAccountsWorker
  include Sidekiq::Worker

  def perform
    return if ThreeScale.config.onpremises
    Account.tenants.inactive_since.find_each(&:suspend!)
  end
end
