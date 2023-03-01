class RemoveAuthorizeNetCCtokenFromAccount < ActiveRecord::Migration[5.2]
  def change
    safety_assured { remove_column :accounts, :credit_card_authorize_net_payment_profile_token }
  end
end
