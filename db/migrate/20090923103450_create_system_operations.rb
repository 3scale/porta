class CreateSystemOperations < ActiveRecord::Migration
  def self.up

    create_table :system_operations do |t|
      t.string :ref
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :system_operations
  end
end
