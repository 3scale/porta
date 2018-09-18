class CreateUsagestats < ActiveRecord::Migration
  def self.up
    create_table :usagestats do |t|
      t.column :id, :int, :null => false, :autoincrement => true
      t.column :cinstance_id, :int, :null => false
      t.column :viewstatus, :string, :default => 'PRIVATE'
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    execute "SET FOREIGN_KEY_CHECKS=0"
    drop_table :usagestats
    execute "SET FOREIGN_KEY_CHECKS=1"
  end
end
