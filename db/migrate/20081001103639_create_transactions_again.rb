class CreateTransactionsAgain < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.belongs_to :cinstance
      t.boolean :actual, :null => false, :default => false
      t.datetime :created_at, :null => false
    end
    
    add_index :transactions, :cinstance_id
  end

  def self.down
    drop_table :slugs
  end
end
