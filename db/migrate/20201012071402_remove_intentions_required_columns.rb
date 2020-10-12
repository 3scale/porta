class RemoveIntentionsRequiredColumns < ActiveRecord::Migration[5.0]
  def up
    safety_assured { remove_column :services, :intentions_required }
  end
end
