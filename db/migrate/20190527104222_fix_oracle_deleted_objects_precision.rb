class FixOracleDeletedObjectsPrecision < ActiveRecord::Migration
  def change
    return unless System::Database.oracle?
    # Safety assured because this will run only for on-prem using Oracle at booting time
    safety_assured { change_column :deleted_objects, :owner_id, :bigint, limit: 8 }
    safety_assured { change_column :deleted_objects, :object_id, :bigint, limit: 8 }
  end
end
