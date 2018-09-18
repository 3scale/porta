class AddTenantIdToLegalTerms < ActiveRecord::Migration
  def self.up
    add_column :legal_term_acceptances, :tenant_id, :integer
    add_column :legal_term_bindings, :tenant_id, :integer
    add_column :legal_term_versions, :tenant_id, :integer
    add_column :legal_terms, :tenant_id, :integer
  end

  def self.down
    remove_column :legal_term_acceptances, :tenant_id
    remove_column :legal_term_bindings, :tenant_id
    remove_column :legal_term_versions, :tenant_id
    remove_column :legal_terms, :tenant_id
  end
end
