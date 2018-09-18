class SetDefaultValueToOnelineDescriptionOfProfiles < ActiveRecord::Migration
  def self.up
    change_table :profiles do |t|
      t.change_default :oneline_description, ''
    end
  end

  def self.down
  end
end
