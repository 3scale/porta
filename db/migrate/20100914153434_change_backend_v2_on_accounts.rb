class ChangeBackendV2OnAccounts < ActiveRecord::Migration
  def self.up
    execute('UPDATE accounts SET backend_v2 = 0 WHERE NOT multiple_cinstances_allowed')
    change_column_default :accounts, :backend_v2, 0
  end

  def self.down
    # Don't bother.
  end
end
