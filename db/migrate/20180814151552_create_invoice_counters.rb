class CreateInvoiceCounters < ActiveRecord::Migration
  def change
    create_table :invoice_counters do |t|
      t.integer :provider_account_id, limit: 8, null: false
      t.string :invoice_prefix, null: false
      t.integer :invoice_count, default: 0
      t.timestamps
    end

    add_index :invoice_counters, %i[provider_account_id invoice_prefix], name: 'index_invoice_counters_provider_prefix', unique: true
  end
end
