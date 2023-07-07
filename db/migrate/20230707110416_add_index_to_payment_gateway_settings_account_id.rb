class AddIndexToPaymentGatewaySettingsAccountId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction! if System::Database.postgres?

  def change
    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :payment_gateway_settings, :account_id, index_options
  end
end
