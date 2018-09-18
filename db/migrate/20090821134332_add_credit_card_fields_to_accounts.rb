class AddCreditCardFieldsToAccounts < ActiveRecord::Migration
  def self.up
    change_table :accounts do |table|
      table.rename :credit_card_number, :credit_card_partial_number
      table.date :credit_card_expires_on
      table.string :credit_card_auth_code
    end

    execute(%Q(UPDATE accounts SET
               credit_card_expires_on = CONCAT(cc_expiry_year, "-", cc_expiry_month, "-01")
               WHERE cc_expiry_year IS NOT NULL OR cc_expiry_month IS NOT NULL))

    change_table :accounts do |table|
      table.remove :cc_expiry_month
      table.remove :cc_expiry_year
      table.remove :credit_card_expiry_date
    end
  end

  def self.down
    change_table :accounts do |table|
      table.string :credit_card_expiry_date, :limit => 10
      table.integer :cc_expiry_year
      table.integer :cc_expiry_month
    end

    execute(%Q(UPDATE account SET
               cc_expiry_year = YEAR(credit_card_expires_on),
               cc_expiry_month = MONTH(credit_card_expires_on)
               WHERE credit_card_expires_on IS NOT NULL))

    change_table :accounts do |table|
      table.remove :credit_card_auth_code
      table.remove :credit_card_expires_on
      table.rename :credit_card_partial_number, :credit_card_number
    end
  end
end
