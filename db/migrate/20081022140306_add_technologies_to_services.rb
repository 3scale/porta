class AddTechnologiesToServices < ActiveRecord::Migration
  def self.up
    change_table :services do |t|
      t.string :technologies, :null => false, :default => ''
    end
  end

  def self.down
    change_table :services do |t|
      t.remove :technologies
    end
  end
end
