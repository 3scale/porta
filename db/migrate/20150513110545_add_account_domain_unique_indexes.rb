class AddAccountDomainUniqueIndexes < ActiveRecord::Migration
  def up
    remove_index :accounts, :domain
    remove_index :accounts, :self_domain

    add_index :accounts, :domain, unique: true
    add_index :accounts, :self_domain, unique: true
  end

  def down
    remove_index :accounts, :domain
    remove_index :accounts, :domain

    add_index :accounts, :domain
    add_index :accounts, :self_domain
  end
end
