class AddAccountIdToLegalTermAcceptances < ActiveRecord::Migration
  def self.up
    add_column :legal_term_acceptances, :account_id, :integer
    add_index :legal_term_acceptances, :account_id
  end

  def self.down
    remove_column :legal_term_acceptances, :account_id
  end
end
