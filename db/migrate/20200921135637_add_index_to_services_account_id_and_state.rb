# frozen_string_literal: true

class AddIndexToServicesAccountIdAndState < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    index_options = {}
    index_options[:algorithm] = :concurrently if System::Database.postgres?
    add_index :services, %i[account_id state], index_options
  end
end
