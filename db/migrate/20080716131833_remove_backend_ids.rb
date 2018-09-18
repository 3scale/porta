class RemoveBackendIds < ActiveRecord::Migration
  def self.up
    change_table :services do |t|
      t.remove :backend_service_id
    end

    change_table :contracts do |t|
      t.remove :backend_template_id
    end

    change_table :cinstances do |t|
      t.remove :backend_id
    end
  end

  def self.down
    change_table :cinstances do |t|
      t.integer :backend_id
    end

    change_table :contracts do |t|
      t.string :backend_template_id
    end

    change_table :services do |t|
      t.string :backend_service_id
    end
  end
end
