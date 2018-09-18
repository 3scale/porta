class AddPaymentGatewayFieldsToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :payment_gateway_type, :string
    add_column :accounts, :payment_gateway_options, :string
  end

  def self.down
    remove_column :accounts, :payment_gateway_options
    remove_column :accounts, :payment_gateway_type
  end
end
