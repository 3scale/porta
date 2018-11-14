# frozen_string_literal: true

class AddServiceToApiDocs < ActiveRecord::Migration
  def change
    add_column :api_docs_services, :service_id, :integer, limit: 8, index: true
    add_foreign_key :api_docs_services, :services
  end
end
