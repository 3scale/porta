class AddNotNullCreatedAtToMappingRules < ActiveRecord::Migration
  def change
    ProxyRule.where(created_at: nil).delete_all
    change_column_null(:proxy_rules, :created_at, false)
  end
end
