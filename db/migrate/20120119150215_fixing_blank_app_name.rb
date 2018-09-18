class FixingBlankAppName < ActiveRecord::Migration
  def self.up
    Cinstance.update_all "name = id", "name is NULL"
  end

  def self.down
  end
end
