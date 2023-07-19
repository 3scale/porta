class AddPrimaryKeyToBackendEvents < ActiveRecord::Migration[5.2]
  def up
    remove_index :backend_events, :id

    if System::Database.mysql?
      execute 'ALTER TABLE backend_events ADD PRIMARY KEY (id)'
    elsif System::Database.postgres?
      execute 'ALTER TABLE backend_events ADD CONSTRAINT backend_events_pk PRIMARY KEY (id)'
    else
      execute 'ALTER TABLE BACKEND_EVENTS MODIFY ID PRIMARY KEY'
    end
  end

  def down
    if System::Database.mysql?
      execute 'ALTER TABLE backend_events DROP PRIMARY KEY'
    elsif System::Database.postgres?
      execute 'ALTER TABLE backend_events DROP CONSTRAINT backend_events_pk'
    else
      execute 'ALTER TABLE BACKEND_EVENTS DROP PRIMARY KEY'
    end

    add_index :backend_events, :id, unique: true
  end
end
