class AddPaymentsEnabledToSettings < ActiveRecord::Migration
  def self.up
    change_table :settings do |t|
      t.rename :module_forum_switch, :forum_enabled
      t.boolean :payments_enabled
    end
  end

  def self.down
    change_table :settings do |t|
      t.remove :payments_enabled
      t.rename :forum_enabled, :module_forum_switch
    end
  end
end
