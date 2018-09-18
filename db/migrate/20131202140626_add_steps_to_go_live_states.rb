class AddStepsToGoLiveStates < ActiveRecord::Migration
  def change
    add_column :go_live_states, :steps, :text
  end
end
