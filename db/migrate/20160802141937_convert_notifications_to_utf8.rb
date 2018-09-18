class ConvertNotificationsToUtf8 < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE notifications convert to character set utf8;'
  end

  def down
    execute 'ALTER TABLE notifications convert to character set latin1;'
  end
end
