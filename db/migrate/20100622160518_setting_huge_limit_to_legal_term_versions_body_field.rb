class SettingHugeLimitToLegalTermVersionsBodyField < ActiveRecord::Migration
  def self.up
    change_column :legal_term_versions, :body, :string, :limit => 2147483647
  end

  def self.down
    change_column :legal_term_versions, :body, :text
  end
end
