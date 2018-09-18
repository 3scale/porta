class AddPartnerIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :partner_id, :integer
  end
end
