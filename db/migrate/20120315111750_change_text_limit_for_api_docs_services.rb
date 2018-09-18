class ChangeTextLimitForApiDocsServices < ActiveRecord::Migration
  def self.up
    change_column :api_docs_services, :body, :text, :limit => 2147483647
  end

  def self.down
    change_column :api_docs_services, :body, :text
  end
end
