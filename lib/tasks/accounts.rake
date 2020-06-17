namespace :accounts do

  desc "Count bought cinstnaces for each account"
  task count_bought_cinstances: :environment do
    Account.select(:id).find_each do |account|
      Account.reset_counters(account.id, :bought_cinstances)
    end
  end

end
