class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.belongs_to :cinstance
      t.belongs_to :metric
      t.integer :value
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :transactions
  end
end
