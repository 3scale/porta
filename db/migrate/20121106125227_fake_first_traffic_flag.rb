class FakeFirstTrafficFlag < ActiveRecord::Migration
  def self.up
    Cinstance.update_all( "first_traffic_at = '2000-01-01 00:00:00'" )
  end

  def self.down
  end
end
