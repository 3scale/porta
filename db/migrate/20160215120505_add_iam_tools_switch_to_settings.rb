class AddIamToolsSwitchToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :iam_tools_switch, :string, default: 'denied', null: false
  end
end
