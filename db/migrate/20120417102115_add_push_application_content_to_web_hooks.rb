class AddPushApplicationContentToWebHooks < ActiveRecord::Migration
  def self.up
    add_column :web_hooks, :push_application_content_type, :boolean, :default => true
    execute("UPDATE web_hooks SET push_application_content_type = 1")
  end

  def self.down
    remove_column :web_hooks, :push_application_content_type
  end
end
