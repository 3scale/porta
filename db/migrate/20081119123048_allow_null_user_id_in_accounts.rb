class AllowNullUserIdInAccounts < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.change :user_id, :integer, :null => true
    end
  end

  def self.down
    # I guess it's not necessary to revert this...
  end
end
