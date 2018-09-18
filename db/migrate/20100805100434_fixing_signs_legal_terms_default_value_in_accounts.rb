class FixingSignsLegalTermsDefaultValueInAccounts < ActiveRecord::Migration
  def self.up
    change_column :accounts, :signs_legal_terms, :boolean, :default => true
  end

  def self.down
    # no down, it will render an invalid db state
  end
end
