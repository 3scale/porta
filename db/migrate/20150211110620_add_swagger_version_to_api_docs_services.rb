class AddSwaggerVersionToApiDocsServices < ActiveRecord::Migration
  def up
    add_column :api_docs_services, :swagger_version, :string
    ApiDocs::Service.reset_column_information

    ApiDocs::Service.all.each do | api_docs_service |
      version = if api_docs_service.swagger?
                  "1.2"
                else
                  "1.0"
                end
      api_docs_service.update_column :swagger_version, version
    end
  end

  def down
    remove_column :api_docs_services, :swagger_version
  end
end
