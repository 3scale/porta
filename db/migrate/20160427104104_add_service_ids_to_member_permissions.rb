class AddServiceIdsToMemberPermissions < ActiveRecord::Migration
  def change
    add_column :member_permissions, :service_ids, :binary
  end
end
