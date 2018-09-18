class AddAccountIdToLegalTerms < ActiveRecord::Migration
  def self.up
    add_column :legal_terms, :account_id, :integer
    add_index :legal_terms, :account_id
  end

  def self.down
    remove_column :legal_terms, :account_id
  end
end
