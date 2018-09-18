class AddSwaggerToApiDocsService < ActiveRecord::Migration
  def change
    add_column :api_docs_services, :swagger, :boolean, default: false
  end
end
