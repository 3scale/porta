# frozen_string_literal: true

class AddPaymentMethodIdToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :payment_method_id, :string
  end
end
