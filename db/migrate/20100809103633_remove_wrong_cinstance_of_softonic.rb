class RemoveWrongCinstanceOfSoftonic < ActiveRecord::Migration

  def self.up
    Cinstance.delete(552753741)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

end

