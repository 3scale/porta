class AddMoreSettingsColumnsToWebhooks < ActiveRecord::Migration
  def self.up
    change_table(:web_hooks) do |t|
      t.column :account_plan_changed_on, :boolean, :default => false

      t.column :application_plan_changed_on,     :boolean, :default => false
      t.column :application_user_key_updated_on, :boolean, :default => false
      t.column :application_key_created_on,      :boolean, :default => false
      t.column :application_key_deleted_on,      :boolean, :default => false
    end
  end

  def self.down
    change_table(:web_hooks) do |t|
      t.remove :account_plan_changed_on

      t.remove :application_plan_changed_on
      t.remove :application_user_key_updated_on
      t.remove :application_key_created_on
      t.remove :application_key_deleted_on
    end
  end
end
