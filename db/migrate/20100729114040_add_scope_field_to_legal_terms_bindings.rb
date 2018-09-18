class AddScopeFieldToLegalTermsBindings < ActiveRecord::Migration
  def self.up
    add_column :legal_term_bindings, :scope, :string
  end

  def self.down
    remove_column :legal_term_bindings, :scope
  end
end
