class AddMappingsBubbleToBubbles < ActiveRecord::Migration
  def change
    add_column :onboardings, :bubble_mapping_state, :string
  end
end
