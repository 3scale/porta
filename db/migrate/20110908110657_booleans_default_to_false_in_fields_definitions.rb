class BooleansDefaultToFalseInFieldsDefinitions < ActiveRecord::Migration
  def self.up
    change_column "fields_definitions", "hidden",    :boolean, :default => false
    change_column "fields_definitions", "read_only", :boolean, :default => false
    change_column "fields_definitions", "required",  :boolean, :default => false
  end

  def self.down
  end
end
