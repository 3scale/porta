class RemovePaidAtFromPaymentItems < ActiveRecord::Migration
  def self.up
    change_table :payment_items do |t|
      t.remove :paid_at
    end
  end

  def self.down
    change_table :payment_items do |t|
      t.datetime :paid_at
    end
  end
end
