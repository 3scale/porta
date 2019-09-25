# frozen_string_literal: true

class EnforceUniquenessAssociationServiceBackendApi < ActiveRecord::Migration
  disable_ddl_transaction! if System::Database.postgres?

  def change
    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :backend_api_configs, %i[backend_api_id service_id], index_options.merge({unique: true})
  end
end
