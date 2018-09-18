class AddAuthorizeNetCCtokenToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :credit_card_authorize_net_payment_profile_token, :string
  end

  def self.down
    remove_column :accounts, :credit_card_authorize_net_payment_profile_token
  end
end
