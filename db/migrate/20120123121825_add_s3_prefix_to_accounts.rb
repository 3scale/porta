class AddS3PrefixToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :s3_prefix, :string #, :null => false
  end

  def self.down
    remove_column :accounts, :s3_prefix
  end
end
