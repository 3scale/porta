class ChangeChoicesToTextInFieldsDefinitions < ActiveRecord::Migration
  def self.up
    change_column "fields_definitions", "choices",    :text
  end

  def self.down
    change_column "fields_definitions", "choices",    :string
  end
end
