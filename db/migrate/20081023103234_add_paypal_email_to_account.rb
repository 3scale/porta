class AddPaypalEmailToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :paypal_email, :string
    add_column :accounts, :paypal_name, :string

  end

  def self.down
   remove_column :accounts, :paypal_name
   remove_column :accounts, :paypal_email
  end
end
