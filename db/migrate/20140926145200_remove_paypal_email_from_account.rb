class RemovePaypalEmailFromAccount < ActiveRecord::Migration

  def self.up
   remove_column :accounts, :paypal_name
   remove_column :accounts, :paypal_email
  end

  def self.down
    add_column :accounts, :paypal_email, :string
    add_column :accounts, :paypal_name, :string
  end
end
