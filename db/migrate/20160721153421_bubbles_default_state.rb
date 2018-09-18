class BubblesDefaultState < ActiveRecord::Migration
  def up
    Onboarding.where(bubble_mapping_state: nil).update_all(bubble_mapping_state: 'mapping_done')
    Onboarding.where(bubble_limit_state: nil).update_all(bubble_limit_state: 'limit_done')
  end
end
