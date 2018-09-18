
require 'active_record/fixtures'

class Devfixtures2 < ActiveRecord::Migration
  def self.up
    
    #DISABLED - can be removed!! - use "rake db:fixtures:load" instead.
   # directory = File.join(File.dirname(__FILE__), "../../test/fixtures") 
    #Fixtures.create_fixtures(directory, "posts") 
    
  end

  def self.down
    #do nothing
  end
end
