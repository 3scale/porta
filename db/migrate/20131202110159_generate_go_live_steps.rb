class GenerateGoLiveSteps < ActiveRecord::Migration
  def up
    Account.transaction do
      Account.providers.find_each do |account|
        account.create_go_live_state
      end
    end
  end
end
