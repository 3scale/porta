class NormalizePlansStates < ActiveRecord::Migration
  def self.up
    execute('UPDATE plans SET state = "hidden" WHERE state <> "published"')
  end

  def self.down
    # Don't bother...
  end
end
