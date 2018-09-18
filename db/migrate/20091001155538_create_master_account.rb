class CreateMasterAccount < ActiveRecord::Migration
  def self.up
  end

  def self.down
    say_with_time('Deassociating provider accounts from master account') do
      Account.master.buyer_accounts.each do |account|
        account.bought_cinstances.each(&:destroy)
        account.provider_account = nil
        account.save!
      end
    end

    say_with_time('Removing master flag from master account') do
      account = Account.master
      account.master = nil
      account.save!
    end
  end
end
