class AddBalancesToAccount < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.decimal :buyerbalance, :precision => 10, :scale => 2, :default => 0
      t.decimal :providerbalance, :precision => 10, :scale => 2, :default => 0
    end
  end

  def self.down
    change_table :accounts do |t|
      t.remove :buyerbalance
      t.remove :providerbalance
    end
  end
end
