class AddTenantIdColumns < ActiveRecord::Migration
  def self.up
    add_column :accounts, :tenant_id, :integer
    add_column :alerts, :tenant_id, :integer
    add_column :app_exhibits, :tenant_id, :integer
    add_column :assets, :tenant_id, :integer
    add_column :audits, :tenant_id, :integer
    add_column :billing_strategies, :tenant_id, :integer
    add_column :cinstances, :tenant_id, :integer
    add_column :configuration_values, :tenant_id, :integer
    add_column :end_user_plans, :tenant_id, :integer
    add_column :features, :tenant_id, :integer
    add_column :features_plans, :tenant_id, :integer
    add_column :fields_definitions, :tenant_id, :integer
    add_column :forums, :tenant_id, :integer
    add_column :invitations, :tenant_id, :integer
    add_column :invoices, :tenant_id, :integer
    add_column :line_items, :tenant_id, :integer
    add_column :liquid_template_versions, :tenant_id, :integer if table_exists?(:liquid_template_versions)
    add_column :liquid_templates, :tenant_id, :integer if table_exists?(:liquid_templates)
    add_column :mail_dispatch_rules, :tenant_id, :integer
    add_column :message_recipients, :tenant_id, :integer
    add_column :messages, :tenant_id, :integer
    add_column :metrics, :tenant_id, :integer
    add_column :moderatorships, :tenant_id, :integer
    add_column :payment_transactions, :tenant_id, :integer
    add_column :plan_metrics, :tenant_id, :integer
    add_column :plans, :tenant_id, :integer
    add_column :posts, :tenant_id, :integer
    add_column :pricing_rules, :tenant_id, :integer
    add_column :profiles, :tenant_id, :integer
    add_column :services, :tenant_id, :integer
    add_column :settings, :tenant_id, :integer
    add_column :slugs, :tenant_id, :integer
    add_column :topic_categories, :tenant_id, :integer
    add_column :topics, :tenant_id, :integer
    add_column :usage_limits, :tenant_id, :integer
    add_column :user_topics, :tenant_id, :integer
    add_column :users, :tenant_id, :integer
    add_column :web_hooks, :tenant_id, :integer
    add_column :wiki_pages, :tenant_id, :integer
  end

  def self.down
    remove_column :accounts, :tenant_id
    remove_column :alerts, :tenant_id
    remove_column :app_exhibits, :tenant_id
    remove_column :assets, :tenant_id
    remove_column :audits, :tenant_id
    remove_column :billing_strategies, :tenant_id
    remove_column :cinstances, :tenant_id
    remove_column :configuration_values, :tenant_id
    remove_column :end_user_plans, :tenant_id
    remove_column :features, :tenant_id
    remove_column :features_plans, :tenant_id
    remove_column :fields_definitions, :tenant_id
    remove_column :forums, :tenant_id
    remove_column :invitations, :tenant_id
    remove_column :invoices, :tenant_id
    remove_column :line_items, :tenant_id
    remove_column :liquid_template_versions, :tenant_id
    remove_column :liquid_templates, :tenant_id
    remove_column :mail_dispatch_rules, :tenant_id
    remove_column :message_recipients, :tenant_id
    remove_column :messages, :tenant_id
    remove_column :metrics, :tenant_id
    remove_column :moderatorships, :tenant_id
    remove_column :payment_transactions, :tenant_id
    remove_column :plan_metrics, :tenant_id
    remove_column :plans, :tenant_id
    remove_column :posts, :tenant_id
    remove_column :pricing_rules, :tenant_id
    remove_column :profiles, :tenant_id
    remove_column :services, :tenant_id
    remove_column :settings, :tenant_id
    remove_column :slugs, :tenant_id
    remove_column :topic_categories, :tenant_id
    remove_column :topics, :tenant_id
    remove_column :usage_limits, :tenant_id
    remove_column :user_topics, :tenant_id
    remove_column :users, :tenant_id
    remove_column :web_hooks, :tenant_id
    remove_column :wiki_pages, :tenant_id
  end
end
