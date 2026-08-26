# frozen_string_literal: true

class ChangeAssociatedIdToBigint < ActiveRecord::Migration[7.1]
  disable_ddl_transaction! if System::Database.postgres?

  def up
    return if System::Database.oracle?

    safety_assured do
      change_column :audits, :associated_id, :bigint
    end
  end
end
