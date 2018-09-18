class SettingHugeLimitToLegalTermsBodyField < ActiveRecord::Migration
  def self.up
    change_column :legal_terms, :body, :string, :limit => 2147483647
  end

  def self.down
    change_column :legal_terms, :body, :text
  end
end
