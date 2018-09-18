class CreateBackendEvents < ActiveRecord::Migration
  def change
    create_table :backend_events, id: false do |t|
      t.integer :id, limit: 8, null: false, default: nil
      t.text :data

      t.timestamps
    end

    add_index :backend_events, :id, unique: true
  end
end
