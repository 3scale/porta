# HACK: create this dummy class, because it's now called differently.
class LiquidPage < ActiveRecord::Base
  acts_as_versioned
end

class AddVersionsTable < ActiveRecord::Migration
  def self.up
    LiquidPage.create_versioned_table    
  end

  def self.down
    LiquidPage.drop_versioned_table
  end
end
