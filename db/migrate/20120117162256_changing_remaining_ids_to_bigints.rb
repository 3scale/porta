class ChangingRemainingIdsToBigints < ActiveRecord::Migration
  def self.up
    change_column :content_type_groups, :id, "bigint auto_increment"
    change_column :content_types, :id, "bigint auto_increment"
    change_column :content_types, :content_type_group_id, "bigint"
    change_column :countries, :id, "bigint auto_increment"
    change_column :group_permissions, :permission_id, "bigint"
    change_column :group_type_permissions, :id, "bigint auto_increment"
    change_column :group_type_permissions, :group_type_id, "bigint"
    change_column :group_type_permissions, :permission_id, "bigint"
    change_column :group_types, :id, "bigint auto_increment"
    change_column :permissions, :id, "bigint auto_increment"
    change_column :system_operations, :id, "bigint auto_increment"
    change_column :accounts, :country_id, "bigint"
    change_column :mail_dispatch_rules, :system_operation_id, "bigint"
    change_column :messages, :system_operation_id, "bigint"
  end

  def self.down
    change_column :content_type_groups, :id, :integer
    change_column :content_types, :id, :integer
    change_column :content_types, :content_type_group_id, :integer
    change_column :countries, :id, :integer
    change_column :group_permissions, :permission_id, :integer
    change_column :group_type_permissions, :id, :integer
    change_column :group_type_permissions, :group_type_id, :integer
    change_column :group_type_permissions, :permission_id, :integer
    change_column :group_types, :id, :integer
    change_column :permissions, :id, :integer
    change_column :system_operations, :id, :integer
    change_column :accounts, :country_id, :integer
    change_column :mail_dispatch_rules, :system_operation_id, :integer
    change_column :messages, :system_operation_id, :integer
  end
end
