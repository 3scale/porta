class CreatePaymentDetails < ActiveRecord::Migration
  def change
    create_table :payment_details do |t|
      t.references :account, index: true, foreign_key: { on_delete: :cascade }, type: :bigint
      t.string :buyer_reference
      t.string :payment_service_reference
      t.string :credit_card_partial_number
      t.date :credit_card_expires_on

      t.timestamps null: false
    end

    add_index :payment_details, [:account_id, :buyer_reference]
    add_index :payment_details, [:account_id, :payment_service_reference], name: 'index_payment_details_on_account_id_and_payment_ref'
  end
end
