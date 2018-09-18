class AddRecentToGoLiveStates < ActiveRecord::Migration
  def change
    add_column :go_live_states, :recent, :string
  end
end
