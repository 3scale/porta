class CreatePaymentItems < ActiveRecord::Migration
  def self.up
    create_table :payment_items do |t|
      t.belongs_to :cinstance
      t.decimal :cost, :precision => 10, :scale => 2
      t.datetime :period_start
      t.datetime :period_end
      t.timestamps
    end
  end

  def self.down
    drop_table :payment_items
  end
end
