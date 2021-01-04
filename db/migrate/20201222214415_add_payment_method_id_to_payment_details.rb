# frozen_string_literal: true

class AddPaymentMethodIdToPaymentDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :payment_details, :payment_method_id, :string
  end
end
