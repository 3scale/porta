class SetServicesBackendVersionDefaultTo1 < ActiveRecord::Migration
  def up
    change_column_default :services, :backend_version, '1'
  end

  def down
    change_column_default :services, :backend_version, '2'
  end
end
