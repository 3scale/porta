# frozen_string_literal: true

namespace :accounts do

  desc "Count bought cinstnaces for each account"
  task reset_bought_cinstances_count: :environment do
    accounts = Account.select(:id)
    progress = ProgressCounter.new(accounts.count)

    accounts.find_each do |account|
      Account.reset_counters(account.id, :bought_cinstances)
      progress.call
    end
  end

end
