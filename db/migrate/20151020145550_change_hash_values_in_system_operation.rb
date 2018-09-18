class ChangeHashValuesInSystemOperation < ActiveRecord::Migration

  def up
    SystemOperation.where(name: 'Service subscription cancelation').update_all(name: 'Service subscription cancellation')
  end

  def down
    SystemOperation.where(name: 'Service subscription cancellation').update_all(name: 'Service subscription cancelation')
  end

end
