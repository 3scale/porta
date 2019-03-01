class AddPositionToMappingRules < ActiveRecord::Migration
  def change
    add_column :proxy_rules, :position, :integer
  end
end
