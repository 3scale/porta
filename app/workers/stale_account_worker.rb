# frozen_string_literal: true

class StaleAccountWorker
  include Sidekiq::Worker

  def perform
    return if ThreeScale.config.onpremises
    Account.tenants.suspended_since.find_each(&:schedule_for_deletion!)
  end
end
