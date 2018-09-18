class AddSupportEmailsToAccounts < ActiveRecord::Migration
  def self.up
    change_table :accounts do |a|
      a.string :support_email
      a.string :finance_support_email
    end
  end

  def self.down
    change_table :accounts do |a|
      a.remove :support_email
      a.remove :finance_support_email
    end
  end
end
