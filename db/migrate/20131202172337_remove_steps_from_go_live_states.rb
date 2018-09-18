class RemoveStepsFromGoLiveStates < ActiveRecord::Migration
  def change
    remove_column :go_live_states, :step1
    remove_column :go_live_states, :step2
    remove_column :go_live_states, :step3
    remove_column :go_live_states, :step4
    remove_column :go_live_states, :step5
  end

end
