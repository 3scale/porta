class DisassociateMasterAccountFromItself < ActiveRecord::Migration
  def self.up
    execute('UPDATE accounts SET provider_account_id = NULL WHERE master LIMIT 1')
  end

  def self.down
    execute('UPDATE accounts SET provider_account_id = id WHERE master LIMIT 1')
  end
end
