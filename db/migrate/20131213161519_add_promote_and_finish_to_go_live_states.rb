class AddPromoteAndFinishToGoLiveStates < ActiveRecord::Migration
  def change
    add_column :go_live_states, :promote, :boolean, default: false
    add_column :go_live_states, :finished, :boolean, default: true
  end
end
