# frozen_string_literal: true

class AddReferenceToPaymentIntents < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_column :payment_intents, :reference, :string

    index_options = { unique: true }
    index_options[:algorithm] = :concurrently if System::Database.postgres?
    add_index :payment_intents, :reference, index_options
  end
end
