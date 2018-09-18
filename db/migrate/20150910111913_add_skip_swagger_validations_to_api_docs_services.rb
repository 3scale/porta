class AddSkipSwaggerValidationsToApiDocsServices < ActiveRecord::Migration
  def change
    add_column :api_docs_services, :skip_swagger_validations, :boolean, default: false
  end
end
