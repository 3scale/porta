class ChangeAccountIdToProviderIdInGroups < ActiveRecord::Migration
  def self.up
    rename_column :cms_groups, :account_id, :provider_id

    CMS::Group.reset_column_information
    change_column_null :cms_groups, :provider_id , false
  end

  def self.down
    rename_column :cms_groups, :provider_id, :account_id
    CMS::Group.reset_column_information
    change_column_null :cms_groups, :account_id , true

  end
end
