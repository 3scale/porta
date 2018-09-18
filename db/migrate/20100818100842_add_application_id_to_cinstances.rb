class AddApplicationIdToCinstances < ActiveRecord::Migration
  def self.up
    add_column :cinstances, :application_id, :string
    add_index  :cinstances, :application_id

    execute('UPDATE cinstances SET application_id = id')
  end

  def self.down
    remove_column :cinstances, :application_id
  end
end
