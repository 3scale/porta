class CreateExternaltransactions < ActiveRecord::Migration
  def self.up
    create_table :externaltransactions do |t|
      t.belongs_to :account
      t.string :transactiontype, :default => 'INCOMING' #should be either "INCOMING" or "OUTGOING"
      t.string :currency, :default => 'EUR', :null => false
      t.decimal :amount, :precision => 10, :scale => 2, :default => 0, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :externaltransactions
  end
end
