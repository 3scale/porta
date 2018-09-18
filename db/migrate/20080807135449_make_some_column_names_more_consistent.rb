class MakeSomeColumnNamesMoreConsistent < ActiveRecord::Migration
  def self.up
    change_table :services do |t|
      t.rename :title, :name
    end
    
    change_table :contracts do |t|
      t.rename :contractname, :name
      t.rename :contractfulllegal, :full_legal
      t.rename :contractrights, :rights
    end
    
    change_table :pricing_rules do |t|
      t.rename :price_per_unit, :cost_per_unit
    end
  end

  def self.down
    change_table :pricing_rules do |t|
      t.rename :cost_per_unit, :price_per_unit
    end
    
    change_table :contracts do |t|
      t.rename :name, :contractname
      t.rename :full_legal, :contractfulllegal
      t.rename :rights, :contractrights
    end
    
    change_table :services do |t|
      t.rename :name, :title
    end
  end
end
