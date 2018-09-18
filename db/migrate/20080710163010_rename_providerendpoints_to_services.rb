class RenameProviderendpointsToServices < ActiveRecord::Migration
  def self.up
    rename_table :providerendpoints, :services
    execute "ALTER TABLE contracts DROP FOREIGN KEY fk_ct_providerendpoint_id"
    change_table :contracts do |t|
      t.rename :providerendpoint_id, :service_id
    end

    # Is this needed?
    execute "ALTER TABLE contracts ADD FOREIGN KEY fk_contracts_service_id (service_id) REFERENCES services(id);"
  end

  def self.down
    execute "ALTER TABLE contracts DROP FOREIGN KEY fk_contracts_service_id"
    change_table :contracts do |t|
      t.rename :service_id, :providerendpoint_id
    end
    rename_table :services, :providerendpoints
    execute "ALTER TABLE contracts ADD FOREIGN KEY fk_ct_providerendpoint_id (providerendpoint_id) REFERENCES providerendpoints(id);"
  end
end
