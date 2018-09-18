class AddKeyToServiceTransactions < ActiveRecord::Migration
  def self.up
    change_table :service_transactions do |t|
      t.string :key, :limit => 64
      t.index :key, :unique => true
    end
  end

  def self.down
    change_table :service_transactions do |t|
      t.remove :key
    end
  end
end
