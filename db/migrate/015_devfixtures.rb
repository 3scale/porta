
require 'active_record/fixtures'

class Devfixtures < ActiveRecord::Migration
  def self.up
#
#    #DISABLED - can be removed!! - use "rake db:fixtures:load" instead.
#    directory = File.join(File.dirname(__FILE__), "../../test/fixtures")
#    Fixtures.create_fixtures(directory, "users")
#    Fixtures.create_fixtures(directory, "accounts")
#    Fixtures.create_fixtures(directory, "profiles")
#    Fixtures.create_fixtures(directory, "providerendpoints")
#    Fixtures.create_fixtures(directory, "contracts")
#    Fixtures.create_fixtures(directory, "cinstances")
#    Fixtures.create_fixtures(directory, "usagestats")
#    Fixtures.create_fixtures(directory, "usagestatdatas")
#    
  end

  def self.down
    #do nothing
  end
end
