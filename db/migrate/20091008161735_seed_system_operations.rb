class SeedSystemOperations < ActiveRecord::Migration
  def self.up
    
    SystemOperation.delete_all
    operations = []
    operations << {:ref => 'user_signup', :name => 'New user signup'}
    operations << {:ref => 'plan_change', :name => 'Plan change by a user'}
    operations << {:ref => 'new_forum_post', :name => "New forum post"}
    operations << {:ref => 'cinstance_cancellation', :name => 'User cancels account'} 
    operations << {:ref => 'weekly_reports', :name => 'Weekly aggregate reports'}
    operations << {:ref => 'daily_reports', :name => 'Daily aggregate reports'}

    SystemOperation.create(operations)
    
  end

  def self.down
    SystemOperation.delete_all    
  end
end
