class AddLimitsBubbleToBubbles < ActiveRecord::Migration
  def change
    add_column :onboardings, :bubble_limit_state, :string
  end
end
