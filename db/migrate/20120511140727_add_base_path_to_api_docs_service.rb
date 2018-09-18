class AddBasePathToApiDocsService < ActiveRecord::Migration
  def self.up
    model = ApiDocs::Service

    add_column :api_docs_services, :base_path, :string
    docs = model.connection.select_all "SELECT id, body FROM api_docs_services"

    docs.each do |columns|
      path = JSON.parse(columns['body'])['basePath'] rescue nil
      next unless path.present?

      assigns = model.send(:sanitize_sql_for_assignment, :base_path => path)
      condition = model.send(:sanitize_sql_for_conditions, :id => columns['id'])

      execute "UPDATE api_docs_services SET #{assigns} WHERE #{condition}"
    end
  end

  def self.down
    remove_column :api_docs_services, :base_path
  end
end
