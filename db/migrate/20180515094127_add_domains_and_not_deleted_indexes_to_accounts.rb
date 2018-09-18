class AddDomainsAndNotDeletedIndexesToAccounts < ActiveRecord::Migration
  def change
    add_index :accounts, %i[domain deleted_at]
    add_index :accounts, %i[self_domain deleted_at]
  end
end
