class CreatePaymentIntents < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    create_table :payment_intents do |t|
      t.references :invoice, null: false
      t.string :payment_intent_id
      t.string :state
      t.integer :tenant_id, limit: 8
      t.timestamps null: false
    end

    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :payment_intents, :payment_intent_id, index_options
    add_index :payment_intents, :state, index_options
  end
end
