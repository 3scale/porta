class CreateFieldsDefinitions < ActiveRecord::Migration
  def self.up
    create_table :fields_definitions do |t|
      t.integer :provider_id
      t.text :fields

      t.timestamps
    end
  end

  def self.down
    drop_table :fields_definitions
  end
end
