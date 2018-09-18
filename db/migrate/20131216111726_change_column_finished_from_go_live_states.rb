class ChangeColumnFinishedFromGoLiveStates < ActiveRecord::Migration
  def up
    change_column :go_live_states, :finished, :boolean, default: false
  end

  def down
    change_column :go_live_states, :finished, :boolean, default: true
  end
end
