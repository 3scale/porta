class FixActiveDocsServices < ActiveRecord::Migration
  def self.up
    change_column :api_docs_services, :account_id, :integer, :limit => 8
    ApiDocs::Service.update_all "account_id = tenant_id"
  end

  def self.down
    change_column :api_docs_services, :account_id, :integer
  end
end
