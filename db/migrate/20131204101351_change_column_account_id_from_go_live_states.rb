class ChangeColumnAccountIdFromGoLiveStates < ActiveRecord::Migration
  def change
    change_column :go_live_states, :account_id, :integer, limit: 8
  end
end
