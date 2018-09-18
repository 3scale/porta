class AddFieldsToService < ActiveRecord::Migration
  def self.up
    add_column :services, :tech_support_email, :string
    add_column :services, :admin_support_email, :string
    add_column :services, :credit_card_support_email, :string
    remove_column :accounts, :credit_card_email
  end

  def self.down
    remove_column :services, :credit_card_support_email
    remove_column :services, :admin_support_email
    remove_column :services, :tech_support_email
  end
end
