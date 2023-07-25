class AddPrimaryKeyToBackendEvents < ActiveRecord::Migration[5.2]
  def up
    if System::Database.mysql?
      execute 'ALTER TABLE backend_events ADD PRIMARY KEY (id)'
      remove_index :backend_events, :id
    elsif System::Database.postgres?
      execute 'ALTER TABLE backend_events ADD CONSTRAINT backend_events_pk PRIMARY KEY (id)'
      remove_index :backend_events, :id
    else
      remove_index :backend_events, :id
      execute 'ALTER TABLE BACKEND_EVENTS MODIFY ID PRIMARY KEY'
    end
  end

  def down
    if System::Database.mysql?
      add_index :backend_events, :id, unique: true
      execute 'ALTER TABLE backend_events DROP PRIMARY KEY'
    elsif System::Database.postgres?
      add_index :backend_events, :id, unique: true
      execute 'ALTER TABLE backend_events DROP CONSTRAINT backend_events_pk'
    else
      execute 'ALTER TABLE BACKEND_EVENTS DROP PRIMARY KEY'
      add_index :backend_events, :id, unique: true
    end
  end
end
