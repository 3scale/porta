class AddDiscoveredToApiDocsServices < ActiveRecord::Migration
  def change
    add_column :api_docs_services, :discovered, :boolean, null: true
  end
end
