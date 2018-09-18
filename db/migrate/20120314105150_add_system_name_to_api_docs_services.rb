class AddSystemNameToApiDocsServices < ActiveRecord::Migration
  def self.up
    add_column :api_docs_services, :system_name, :string
  end

  def self.down
    remove_column :api_docs_services, :system_name
  end
end