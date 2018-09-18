class AddSignsLegalTermsToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :signs_legal_terms, :boolean, :defaults => true
  end

  def self.down
    remove_column :accounts, :signs_legal_terms
  end
end
