class RemoveSwaggerFromApiDocsServices < ActiveRecord::Migration
  def up
    remove_column :api_docs_services, :swagger
  end

  def down
    add_column :api_docs_services, :swagger, :string, default: false
    # this should use swagger_version to restore data but idgaf, deal with it.
  end
end
