class AddDataFormatsToServices < ActiveRecord::Migration
  def self.up
    change_table :services do |t|
      t.string :data_formats, :null => false, :default => ''
    end
  end

  def self.down
    change_table :services do |t|
      t.remove :data_formats
    end
  end
end
