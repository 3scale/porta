class AddCreditCardDetailsToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :credit_card_number, :string, :limit => 4
    add_column :accounts, :credit_card_email, :string
    add_column :accounts, :credit_card_expiry_date, :string, :limit => 10
  end

  def self.down
    remove_column :accounts, :credit_card_expiry_date
    remove_column :accounts, :credit_card_email
    remove_column :accounts, :credit_card_number
  end
end
