# frozen_string_literal: true

require 'progress_counter'

namespace :accounts do

  desc "Reset the counter of bought_cinstances for all accounts"
  task reset_bought_cinstances_count: :environment do
    accounts = Account.where.not(state: :scheduled_for_deletion)
    progress = ProgressCounter.new(accounts.count)

    accounts.find_each do |account|
      Account.reset_counters(account.id, :bought_cinstances)
      progress.call
    end
  end

end
