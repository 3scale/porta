class RemovePromoteFromGoLiveStates < ActiveRecord::Migration

  def up
    remove_column :go_live_states, :promote
  end

  def down
    add_column :go_live_states, :promote, :boolean
  end
end