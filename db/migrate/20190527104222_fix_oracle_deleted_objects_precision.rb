class FixOracleDeletedObjectsPrecision < ActiveRecord::Migration
  def up
    return unless System::Database.oracle?

    # Safety assured because this will run only for on-prem using Oracle at booting time

    add_column :deleted_objects, :owner_id_tmp,  :bigint, limit: 8
    add_column :deleted_objects, :object_id_tmp, :bigint, limit: 8

    DeletedObject.update_all('owner_id_tmp = owner_id, object_id_tmp = object_id')
    DeletedObject.update_all(owner_id: nil, object_id: nil)

    safety_assured { change_column :deleted_objects, :owner_id,  :bigint, limit: 8 }
    safety_assured { change_column :deleted_objects, :object_id, :bigint, limit: 8 }

    DeletedObject.update_all('owner_id = owner_id_tmp, object_id = object_id_tmp')

    safety_assured { remove_column :deleted_objects, :owner_id_tmp }
    safety_assured { remove_column :deleted_objects, :object_id_tmp }
  end
end
