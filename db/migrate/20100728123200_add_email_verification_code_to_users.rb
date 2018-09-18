class AddEmailVerificationCodeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email_verification_code, :string
  end

  def self.down
    remove_column :users, :email_verification_code
  end
end
