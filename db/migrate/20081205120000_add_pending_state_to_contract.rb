class AddPendingStateToContract < ActiveRecord::Migration
  def self.up
    add_column :contracts, :live_state, :string
    execute('UPDATE contracts SET live_state = state')
  end

  def self.down
    remove_column :contracts, :live_state
  end
end
