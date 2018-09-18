class TurnOffNewForumPostDispatchRule < ActiveRecord::Migration
  def self.up
    operation = SystemOperation.for('new_forum_post')
    if operation
      MailDispatchRule.find(:all, :conditions => ["system_operation_id = ?", operation.id]).each do |m|
        m.update_attribute(:dispatch, false)
      end
    end
  end

  def self.down
  end
end
