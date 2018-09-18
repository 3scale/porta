class RemoveHostFromApiDocsServices < ActiveRecord::Migration
  def up
    remove_column :api_docs_services, :host
  end

  def down
    add_column :api_docs_services, :host, :string
  end
end
