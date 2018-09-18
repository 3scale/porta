class WebHookActiveDefaultsToFalse < ActiveRecord::Migration
  def self.up
    change_column_default :web_hooks, :active, false
  end

  def self.down
    change_column_default :web_hooks, :active, true
  end
end
