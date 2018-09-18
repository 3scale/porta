class AddPaymentTypeToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :payment_type, :string, :null => false, :default => 'prepaid'
  end

  def self.down
    remove_column :settings, :payment_type
  end
end
