class IncreaseIdsTo64Bit < ActiveRecord::Migration
  def self.up
    change_column :account_group_memberships, :id, "bigint auto_increment"
    change_column :account_group_memberships, :account_id, "bigint"
    change_column :account_group_memberships, :group_id, "bigint"
    change_column :account_group_memberships, :tenant_id, "bigint"
    change_column :accounts, :id, "bigint auto_increment"
    change_column :accounts, :provider_account_id, "bigint"
    change_column :accounts, :default_account_plan_id, "bigint"
    change_column :accounts, :default_service_id, "bigint"
    change_column :accounts, :tenant_id, "bigint"
    change_column :alerts, :id, "bigint auto_increment"
    change_column :alerts, :account_id, "bigint"
    change_column :alerts, :cinstance_id, "bigint"
    change_column :alerts, :alert_id, "bigint"
    change_column :alerts, :tenant_id, "bigint"
    change_column :app_exhibits, :id, "bigint auto_increment"
    change_column :app_exhibits, :account_id, "bigint"
    change_column :app_exhibits, :tenant_id, "bigint"
    change_column :assets, :id, "bigint auto_increment"
    change_column :assets, :account_id, "bigint"
    change_column :assets, :tenant_id, "bigint"
    change_column :attachment_versions, :id, "bigint auto_increment"
    change_column :attachment_versions, :attachment_id, "bigint"
    change_column :attachment_versions, :created_by_id, "bigint"
    change_column :attachment_versions, :updated_by_id, "bigint"
    change_column :attachment_versions, :account_id, "bigint"
    change_column :attachment_versions, :tenant_id, "bigint"
    change_column :attachments, :id, "bigint auto_increment"
    change_column :attachments, :created_by_id, "bigint"
    change_column :attachments, :updated_by_id, "bigint"
    change_column :attachments, :account_id, "bigint"
    change_column :attachments, :tenant_id, "bigint"
    change_column :audits, :id, "bigint auto_increment"
    change_column :audits, :auditable_id, "bigint"
    change_column :audits, :user_id, "bigint"
    change_column :audits, :tenant_id, "bigint"
    change_column :billing_strategies, :id, "bigint auto_increment"
    change_column :billing_strategies, :account_id, "bigint"
    change_column :billing_strategies, :tenant_id, "bigint"
    change_column :blog_comment_versions, :id, "bigint auto_increment"
    change_column :blog_comment_versions, :blog_comment_id, "bigint"
    change_column :blog_comment_versions, :post_id, "bigint"
    change_column :blog_comment_versions, :created_by_id, "bigint"
    change_column :blog_comment_versions, :updated_by_id, "bigint"
    change_column :blog_comment_versions, :tenant_id, "bigint"
    change_column :blog_comments, :id, "bigint auto_increment"
    change_column :blog_comments, :post_id, "bigint"
    change_column :blog_comments, :created_by_id, "bigint"
    change_column :blog_comments, :updated_by_id, "bigint"
    change_column :blog_comments, :tenant_id, "bigint"
    change_column :blog_group_membership_versions, :id, "bigint auto_increment"
    change_column :blog_group_membership_versions, :blog_group_membership_id, "bigint"
    change_column :blog_group_membership_versions, :blog_id, "bigint"
    change_column :blog_group_membership_versions, :group_id, "bigint"
    change_column :blog_group_membership_versions, :created_by_id, "bigint"
    change_column :blog_group_membership_versions, :updated_by_id, "bigint"
    change_column :blog_group_membership_versions, :tenant_id, "bigint"
    change_column :blog_group_memberships, :id, "bigint auto_increment"
    change_column :blog_group_memberships, :blog_id, "bigint"
    change_column :blog_group_memberships, :group_id, "bigint"
    change_column :blog_group_memberships, :created_by_id, "bigint"
    change_column :blog_group_memberships, :updated_by_id, "bigint"
    change_column :blog_group_memberships, :tenant_id, "bigint"
    change_column :blog_post_versions, :id, "bigint auto_increment"
    change_column :blog_post_versions, :blog_post_id, "bigint"
    change_column :blog_post_versions, :blog_id, "bigint"
    change_column :blog_post_versions, :author_id, "bigint"
    change_column :blog_post_versions, :category_id, "bigint"
    change_column :blog_post_versions, :created_by_id, "bigint"
    change_column :blog_post_versions, :updated_by_id, "bigint"
    change_column :blog_post_versions, :account_id, "bigint"
    change_column :blog_post_versions, :tenant_id, "bigint"
    change_column :blog_posts, :id, "bigint auto_increment"
    change_column :blog_posts, :blog_id, "bigint"
    change_column :blog_posts, :author_id, "bigint"
    change_column :blog_posts, :category_id, "bigint"
    change_column :blog_posts, :created_by_id, "bigint"
    change_column :blog_posts, :updated_by_id, "bigint"
    change_column :blog_posts, :account_id, "bigint"
    change_column :blog_posts, :tenant_id, "bigint"
    change_column :blog_versions, :id, "bigint auto_increment"
    change_column :blog_versions, :blog_id, "bigint"
    change_column :blog_versions, :created_by_id, "bigint"
    change_column :blog_versions, :updated_by_id, "bigint"
    change_column :blog_versions, :account_id, "bigint"
    change_column :blog_versions, :tenant_id, "bigint"
    change_column :blogs, :id, "bigint auto_increment"
    change_column :blogs, :created_by_id, "bigint"
    change_column :blogs, :updated_by_id, "bigint"
    change_column :blogs, :account_id, "bigint"
    change_column :blogs, :tenant_id, "bigint"
    change_column :categories, :id, "bigint auto_increment"
    change_column :categories, :category_type_id, "bigint"
    change_column :categories, :parent_id, "bigint"
    change_column :categories, :account_id, "bigint"
    change_column :categories, :tenant_id, "bigint"
    change_column :category_types, :id, "bigint auto_increment"
    change_column :category_types, :account_id, "bigint"
    change_column :category_types, :tenant_id, "bigint"
    change_column :cinstances, :id, "bigint auto_increment"
    change_column :cinstances, :plan_id, "bigint"
    change_column :cinstances, :user_account_id, "bigint"
    change_column :cinstances, :tenant_id, "bigint"
    change_column :configuration_values, :id, "bigint auto_increment"
    change_column :configuration_values, :configurable_id, "bigint"
    change_column :configuration_values, :tenant_id, "bigint"
    change_column :connectors, :id, "bigint auto_increment"
    change_column :connectors, :page_id, "bigint"
    change_column :connectors, :connectable_id, "bigint"
    change_column :connectors, :tenant_id, "bigint"
    change_column :dynamic_view_versions, :id, "bigint auto_increment"
    change_column :dynamic_view_versions, :dynamic_view_id, "bigint"
    change_column :dynamic_view_versions, :created_by_id, "bigint"
    change_column :dynamic_view_versions, :updated_by_id, "bigint"
    change_column :dynamic_view_versions, :account_id, "bigint"
    change_column :dynamic_view_versions, :tenant_id, "bigint"
    change_column :dynamic_views, :id, "bigint auto_increment"
    change_column :dynamic_views, :created_by_id, "bigint"
    change_column :dynamic_views, :updated_by_id, "bigint"
    change_column :dynamic_views, :account_id, "bigint"
    change_column :dynamic_views, :tenant_id, "bigint"
    change_column :end_user_plans, :id, "bigint auto_increment"
    change_column :end_user_plans, :service_id, "bigint"
    change_column :end_user_plans, :tenant_id, "bigint"
    change_column :features, :id, "bigint auto_increment"
    change_column :features, :featurable_id, "bigint"
    change_column :features, :tenant_id, "bigint"
    change_column :features_plans, :plan_id, "bigint"
    change_column :features_plans, :feature_id, "bigint"
    change_column :features_plans, :tenant_id, "bigint"
    change_column :fields_definitions, :id, "bigint auto_increment"
    change_column :fields_definitions, :account_id, "bigint"
    change_column :fields_definitions, :tenant_id, "bigint"
    change_column :file_block_versions, :id, "bigint auto_increment"
    change_column :file_block_versions, :file_block_id, "bigint"
    change_column :file_block_versions, :attachment_id, "bigint"
    change_column :file_block_versions, :created_by_id, "bigint"
    change_column :file_block_versions, :updated_by_id, "bigint"
    change_column :file_block_versions, :account_id, "bigint"
    change_column :file_block_versions, :tenant_id, "bigint"
    change_column :file_blocks, :id, "bigint auto_increment"
    change_column :file_blocks, :attachment_id, "bigint"
    change_column :file_blocks, :created_by_id, "bigint"
    change_column :file_blocks, :updated_by_id, "bigint"
    change_column :file_blocks, :account_id, "bigint"
    change_column :file_blocks, :tenant_id, "bigint"
    change_column :forums, :id, "bigint auto_increment"
    change_column :forums, :account_id, "bigint"
    change_column :forums, :tenant_id, "bigint"
    change_column :group_permissions, :id, "bigint auto_increment"
    change_column :group_permissions, :group_id, "bigint"
    change_column :group_permissions, :tenant_id, "bigint"
    change_column :group_sections, :id, "bigint auto_increment"
    change_column :group_sections, :group_id, "bigint"
    change_column :group_sections, :section_id, "bigint"
    change_column :group_sections, :tenant_id, "bigint"
    change_column :groups, :id, "bigint auto_increment"
    change_column :groups, :account_id, "bigint"
    change_column :groups, :tenant_id, "bigint"
    change_column :html_block_versions, :id, "bigint auto_increment"
    change_column :html_block_versions, :html_block_id, "bigint"
    change_column :html_block_versions, :created_by_id, "bigint"
    change_column :html_block_versions, :updated_by_id, "bigint"
    change_column :html_block_versions, :account_id, "bigint"
    change_column :html_block_versions, :tenant_id, "bigint"
    change_column :html_blocks, :id, "bigint auto_increment"
    change_column :html_blocks, :created_by_id, "bigint"
    change_column :html_blocks, :updated_by_id, "bigint"
    change_column :html_blocks, :account_id, "bigint"
    change_column :html_blocks, :tenant_id, "bigint" 
    change_column :invitations, :id, "bigint auto_increment"
    change_column :invitations, :account_id, "bigint"
    change_column :invitations, :creator_id, "bigint"
    change_column :invitations, :updater_id, "bigint"
    change_column :invitations, :tenant_id, "bigint"
    change_column :invoices, :id, "bigint auto_increment"
    change_column :invoices, :provider_account_id, "bigint"
    change_column :invoices, :buyer_account_id, "bigint"
    change_column :invoices, :tenant_id, "bigint"
    change_column :legal_term_acceptances, :id, "bigint auto_increment"
    change_column :legal_term_acceptances, :legal_term_id, "bigint"
    change_column :legal_term_acceptances, :resource_id, "bigint"
    change_column :legal_term_acceptances, :tenant_id, "bigint"
    change_column :legal_term_acceptances, :account_id, "bigint"
    change_column :legal_term_bindings, :id, "bigint auto_increment"
    change_column :legal_term_bindings, :legal_term_id, "bigint"
    change_column :legal_term_bindings, :resource_id, "bigint"
    change_column :legal_term_bindings, :tenant_id, "bigint"
    change_column :legal_term_versions, :id, "bigint auto_increment"
    change_column :legal_term_versions, :legal_term_id, "bigint"
    change_column :legal_term_versions, :created_by_id, "bigint"
    change_column :legal_term_versions, :updated_by_id, "bigint"
    change_column :legal_term_versions, :tenant_id, "bigint"
    change_column :legal_terms, :id, "bigint auto_increment"
    change_column :legal_terms, :created_by_id, "bigint"
    change_column :legal_terms, :updated_by_id, "bigint"
    change_column :legal_terms, :account_id, "bigint"
    change_column :legal_terms, :tenant_id, "bigint"
    change_column :line_items, :id, "bigint auto_increment"
    change_column :line_items, :invoice_id, "bigint"
    change_column :line_items, :cinstance_id, "bigint"
    change_column :line_items, :metric_id, "bigint"
    change_column :line_items, :tenant_id, "bigint"
    change_column :link_versions, :id, "bigint auto_increment"
    change_column :link_versions, :link_id, "bigint"
    change_column :link_versions, :created_by_id, "bigint"
    change_column :link_versions, :updated_by_id, "bigint"
    change_column :link_versions, :tenant_id, "bigint"
    change_column :links, :id, "bigint auto_increment"
    change_column :links, :created_by_id, "bigint"
    change_column :links, :updated_by_id, "bigint"
    change_column :links, :account_id, "bigint"
    change_column :links, :tenant_id, "bigint"
    change_column :mail_dispatch_rules, :id, "bigint auto_increment"
    change_column :mail_dispatch_rules, :account_id, "bigint"
    change_column :mail_dispatch_rules, :tenant_id, "bigint"
    change_column :message_recipients, :id, "bigint auto_increment"
    change_column :message_recipients, :message_id, "bigint"
    change_column :message_recipients, :receiver_id, "bigint"
    change_column :message_recipients, :tenant_id, "bigint"
    change_column :messages, :id, "bigint auto_increment"
    change_column :messages, :sender_id, "bigint"
    change_column :messages, :tenant_id, "bigint"
    change_column :metrics, :id, "bigint auto_increment"
    change_column :metrics, :service_id, "bigint"
    change_column :metrics, :parent_id, "bigint"
    change_column :metrics, :tenant_id, "bigint"
    change_column :moderatorships, :id, "bigint auto_increment"
    change_column :moderatorships, :forum_id, "bigint"
    change_column :moderatorships, :user_id, "bigint"
    change_column :moderatorships, :tenant_id, "bigint"
    change_column :page_route_options, :id, "bigint auto_increment"
    change_column :page_route_options, :page_route_id, "bigint"
    change_column :page_route_options, :tenant_id, "bigint"
    change_column :page_routes, :id, "bigint auto_increment"
    change_column :page_routes, :page_id, "bigint"
    change_column :page_routes, :tenant_id, "bigint"
    change_column :page_versions, :id, "bigint auto_increment"
    change_column :page_versions, :page_id, "bigint"
    change_column :page_versions, :created_by_id, "bigint"
    change_column :page_versions, :updated_by_id, "bigint"
    change_column :page_versions, :tenant_id, "bigint"
    change_column :pages, :id, "bigint auto_increment"
    change_column :pages, :created_by_id, "bigint"
    change_column :pages, :updated_by_id, "bigint"
    change_column :pages, :account_id, "bigint"
    change_column :pages, :tenant_id, "bigint"
    change_column :payment_transactions, :id, "bigint auto_increment"
    change_column :payment_transactions, :account_id, "bigint"
    change_column :payment_transactions, :invoice_id, "bigint"
    change_column :payment_transactions, :tenant_id, "bigint"
    change_column :plan_metrics, :id, "bigint auto_increment"
    change_column :plan_metrics, :plan_id, "bigint"
    change_column :plan_metrics, :metric_id, "bigint"
    change_column :plan_metrics, :tenant_id, "bigint"
    change_column :plans, :id, "bigint auto_increment"
    change_column :plans, :issuer_id, "bigint"
    change_column :plans, :original_id, "bigint"
    change_column :plans, :tenant_id, "bigint"
    change_column :portlet_attributes, :id, "bigint auto_increment"
    change_column :portlet_attributes, :portlet_id, "bigint"
    change_column :portlet_attributes, :tenant_id, "bigint"
    change_column :portlets, :id, "bigint auto_increment"
    change_column :portlets, :created_by_id, "bigint"
    change_column :portlets, :updated_by_id, "bigint"
    change_column :portlets, :account_id, "bigint"
    change_column :portlets, :tenant_id, "bigint"
    change_column :posts, :id, "bigint auto_increment"
    change_column :posts, :user_id, "bigint"
    change_column :posts, :topic_id, "bigint"
    change_column :posts, :forum_id, "bigint"
    change_column :posts, :tenant_id, "bigint"
    change_column :pricing_rules, :id, "bigint auto_increment"
    change_column :pricing_rules, :metric_id, "bigint"
    change_column :pricing_rules, :plan_id, "bigint"
    change_column :pricing_rules, :tenant_id, "bigint"
    change_column :profiles, :id, "bigint auto_increment"
    change_column :profiles, :account_id, "bigint"
    change_column :profiles, :tenant_id, "bigint"
    change_column :redirects, :id, "bigint auto_increment"
    change_column :redirects, :account_id, "bigint"
    change_column :redirects, :tenant_id, "bigint"
    change_column :section_nodes, :id, "bigint auto_increment"
    change_column :section_nodes, :section_id, "bigint"
    change_column :section_nodes, :node_id, "bigint"
    change_column :section_nodes, :account_id, "bigint"
    change_column :section_nodes, :tenant_id, "bigint"
    change_column :sections, :id, "bigint auto_increment"
    change_column :sections, :account_id, "bigint"
    change_column :sections, :tenant_id, "bigint"
    change_column :services, :id, "bigint auto_increment"
    change_column :services, :account_id, "bigint"
    change_column :services, :default_application_plan_id, "bigint"
    change_column :services, :default_service_plan_id, "bigint"
    change_column :services, :default_end_user_plan_id, "bigint"
    change_column :services, :tenant_id, "bigint"
    change_column :settings, :id, "bigint auto_increment"
    change_column :settings, :account_id, "bigint"
    change_column :settings, :tenant_id, "bigint"
    change_column :slugs, :id, "bigint auto_increment"
    change_column :slugs, :sluggable_id, "bigint"
    change_column :slugs, :tenant_id, "bigint"
    change_column :taggings, :id, "bigint auto_increment"
    change_column :taggings, :tag_id, "bigint"
    change_column :taggings, :taggable_id, "bigint"
    change_column :taggings, :tenant_id, "bigint"
    change_column :tags, :id, "bigint auto_increment"
    change_column :tags, :account_id, "bigint"
    change_column :tags, :tenant_id, "bigint"
    change_column :topic_categories, :id, "bigint auto_increment"
    change_column :topic_categories, :forum_id, "bigint"
    change_column :topic_categories, :tenant_id, "bigint"
    change_column :topics, :id, "bigint auto_increment"
    change_column :topics, :forum_id, "bigint"
    change_column :topics, :user_id, "bigint"
    change_column :topics, :last_post_id, "bigint"
    change_column :topics, :last_user_id, "bigint"
    change_column :topics, :category_id, "bigint"
    change_column :topics, :tenant_id, "bigint"
    change_column :usage_limits, :id, "bigint auto_increment"
    change_column :usage_limits, :metric_id, "bigint"
    change_column :usage_limits, :plan_id, "bigint"
    change_column :usage_limits, :tenant_id, "bigint"
    change_column :user_group_memberships, :id, "bigint auto_increment"
    change_column :user_group_memberships, :user_id, "bigint"
    change_column :user_group_memberships, :group_id, "bigint"
    change_column :user_group_memberships, :tenant_id, "bigint"
    change_column :user_topics, :id, "bigint auto_increment"
    change_column :user_topics, :user_id, "bigint"
    change_column :user_topics, :topic_id, "bigint"
    change_column :user_topics, :tenant_id, "bigint"
    change_column :users, :id, "bigint auto_increment"
    change_column :users, :account_id, "bigint"
    change_column :users, :tenant_id, "bigint"
    change_column :web_hooks, :id, "bigint auto_increment"
    change_column :web_hooks, :account_id, "bigint"
    change_column :web_hooks, :tenant_id, "bigint"
    change_column :wiki_pages, :id, "bigint auto_increment"
    change_column :wiki_pages, :account_id, "bigint"
    change_column :wiki_pages, :tenant_id, "bigint"
  end

  def self.down
    change_column :account_group_memberships, :id, :integer
    change_column :account_group_memberships, :account_id, :integer
    change_column :account_group_memberships, :group_id, :integer
    change_column :account_group_memberships, :tenant_id, :integer
    change_column :accounts, :id, :integer
    change_column :accounts, :provider_account_id, :integer
    change_column :accounts, :default_account_plan_id, :integer
    change_column :accounts, :default_service_id, :integer
    change_column :accounts, :tenant_id, :integer
    change_column :alerts, :id, :integer
    change_column :alerts, :account_id, :integer
    change_column :alerts, :cinstance_id, :integer
    change_column :alerts, :alert_id, :integer
    change_column :alerts, :tenant_id, :integer
    change_column :app_exhibits, :id, :integer
    change_column :app_exhibits, :account_id, :integer
    change_column :app_exhibits, :tenant_id, :integer
    change_column :assets, :id, :integer
    change_column :assets, :account_id, :integer
    change_column :assets, :tenant_id, :integer
    change_column :attachment_versions, :id, :integer
    change_column :attachment_versions, :attachment_id, :integer
    change_column :attachment_versions, :created_by_id, :integer
    change_column :attachment_versions, :updated_by_id, :integer
    change_column :attachment_versions, :account_id, :integer
    change_column :attachment_versions, :tenant_id, :integer
    change_column :attachments, :id, :integer
    change_column :attachments, :created_by_id, :integer
    change_column :attachments, :updated_by_id, :integer
    change_column :attachments, :account_id, :integer
    change_column :attachments, :tenant_id, :integer
    change_column :audits, :id, :integer
    change_column :audits, :auditable_id, :integer
    change_column :audits, :user_id, :integer
    change_column :audits, :tenant_id, :integer
    change_column :billing_strategies, :id, :integer
    change_column :billing_strategies, :account_id, :integer
    change_column :billing_strategies, :tenant_id, :integer
    change_column :blog_comment_versions, :id, :integer
    change_column :blog_comment_versions, :blog_comment_id, :integer
    change_column :blog_comment_versions, :post_id, :integer
    change_column :blog_comment_versions, :created_by_id, :integer
    change_column :blog_comment_versions, :updated_by_id, :integer
    change_column :blog_comment_versions, :tenant_id, :integer
    change_column :blog_comments, :id, :integer
    change_column :blog_comments, :post_id, :integer
    change_column :blog_comments, :created_by_id, :integer
    change_column :blog_comments, :updated_by_id, :integer
    change_column :blog_comments, :tenant_id, :integer
    change_column :blog_group_membership_versions, :id, :integer
    change_column :blog_group_membership_versions, :blog_group_membership_id, :integer
    change_column :blog_group_membership_versions, :blog_id, :integer
    change_column :blog_group_membership_versions, :group_id, :integer
    change_column :blog_group_membership_versions, :created_by_id, :integer
    change_column :blog_group_membership_versions, :updated_by_id, :integer
    change_column :blog_group_membership_versions, :tenant_id, :integer
    change_column :blog_group_memberships, :id, :integer
    change_column :blog_group_memberships, :blog_id, :integer
    change_column :blog_group_memberships, :group_id, :integer
    change_column :blog_group_memberships, :created_by_id, :integer
    change_column :blog_group_memberships, :updated_by_id, :integer
    change_column :blog_group_memberships, :tenant_id, :integer
    change_column :blog_post_versions, :id, :integer
    change_column :blog_post_versions, :blog_post_id, :integer
    change_column :blog_post_versions, :blog_id, :integer
    change_column :blog_post_versions, :author_id, :integer
    change_column :blog_post_versions, :category_id, :integer
    change_column :blog_post_versions, :created_by_id, :integer
    change_column :blog_post_versions, :updated_by_id, :integer
    change_column :blog_post_versions, :account_id, :integer
    change_column :blog_post_versions, :tenant_id, :integer
    change_column :blog_posts, :id, :integer
    change_column :blog_posts, :blog_id, :integer
    change_column :blog_posts, :author_id, :integer
    change_column :blog_posts, :category_id, :integer
    change_column :blog_posts, :created_by_id, :integer
    change_column :blog_posts, :updated_by_id, :integer
    change_column :blog_posts, :account_id, :integer
    change_column :blog_posts, :tenant_id, :integer
    change_column :blog_versions, :id, :integer
    change_column :blog_versions, :blog_id, :integer
    change_column :blog_versions, :created_by_id, :integer
    change_column :blog_versions, :updated_by_id, :integer
    change_column :blog_versions, :account_id, :integer
    change_column :blog_versions, :tenant_id, :integer
    change_column :blogs, :id, :integer
    change_column :blogs, :created_by_id, :integer
    change_column :blogs, :updated_by_id, :integer
    change_column :blogs, :account_id, :integer
    change_column :blogs, :tenant_id, :integer
    change_column :categories, :id, :integer
    change_column :categories, :category_type_id, :integer
    change_column :categories, :parent_id, :integer
    change_column :categories, :account_id, :integer
    change_column :categories, :tenant_id, :integer
    change_column :category_types, :id, :integer
    change_column :category_types, :account_id, :integer
    change_column :category_types, :tenant_id, :integer
    change_column :cinstances, :id, :integer
    change_column :cinstances, :plan_id, :integer
    change_column :cinstances, :user_account_id, :integer
    change_column :cinstances, :tenant_id, :integer
    change_column :configuration_values, :id, :integer
    change_column :configuration_values, :configurable_id, :integer
    change_column :configuration_values, :tenant_id, :integer
    change_column :connectors, :id, :integer
    change_column :connectors, :page_id, :integer
    change_column :connectors, :connectable_id, :integer
    change_column :connectors, :tenant_id, :integer
    change_column :dynamic_view_versions, :id, :integer
    change_column :dynamic_view_versions, :dynamic_view_id, :integer
    change_column :dynamic_view_versions, :created_by_id, :integer
    change_column :dynamic_view_versions, :updated_by_id, :integer
    change_column :dynamic_view_versions, :account_id, :integer
    change_column :dynamic_view_versions, :tenant_id, :integer
    change_column :dynamic_views, :id, :integer
    change_column :dynamic_views, :created_by_id, :integer
    change_column :dynamic_views, :updated_by_id, :integer
    change_column :dynamic_views, :account_id, :integer
    change_column :dynamic_views, :tenant_id, :integer
    change_column :end_user_plans, :id, :integer
    change_column :end_user_plans, :service_id, :integer
    change_column :end_user_plans, :tenant_id, :integer
    change_column :features, :id, :integer
    change_column :features, :featurable_id, :integer
    change_column :features, :tenant_id, :integer
    change_column :features_plans, :plan_id, :integer
    change_column :features_plans, :feature_id, :integer
    change_column :features_plans, :tenant_id, :integer
    change_column :fields_definitions, :id, :integer
    change_column :fields_definitions, :account_id, :integer
    change_column :fields_definitions, :tenant_id, :integer
    change_column :file_block_versions, :id, :integer
    change_column :file_block_versions, :file_block_id, :integer
    change_column :file_block_versions, :attachment_id, :integer
    change_column :file_block_versions, :created_by_id, :integer
    change_column :file_block_versions, :updated_by_id, :integer
    change_column :file_block_versions, :account_id, :integer
    change_column :file_block_versions, :tenant_id, :integer
    change_column :file_blocks, :id, :integer
    change_column :file_blocks, :attachment_id, :integer
    change_column :file_blocks, :created_by_id, :integer
    change_column :file_blocks, :updated_by_id, :integer
    change_column :file_blocks, :account_id, :integer
    change_column :file_blocks, :tenant_id, :integer
    change_column :forums, :id, :integer
    change_column :forums, :account_id, :integer
    change_column :forums, :tenant_id, :integer
    change_column :group_permissions, :id, :integer
    change_column :group_permissions, :group_id, :integer
    change_column :group_permissions, :tenant_id, :integer
    change_column :group_sections, :id, :integer
    change_column :group_sections, :group_id, :integer
    change_column :group_sections, :section_id, :integer
    change_column :group_sections, :tenant_id, :integer
    change_column :groups, :id, :integer
    change_column :groups, :account_id, :integer
    change_column :groups, :tenant_id, :integer
    change_column :html_block_versions, :id, :integer
    change_column :html_block_versions, :html_block_id, :integer
    change_column :html_block_versions, :created_by_id, :integer
    change_column :html_block_versions, :updated_by_id, :integer
    change_column :html_block_versions, :account_id, :integer
    change_column :html_block_versions, :tenant_id, :integer
    change_column :html_blocks, :id, :integer
    change_column :html_blocks, :created_by_id, :integer
    change_column :html_blocks, :updated_by_id, :integer
    change_column :html_blocks, :account_id, :integer
    change_column :html_blocks, :tenant_id, :integer 
    change_column :invitations, :id, :integer
    change_column :invitations, :account_id, :integer
    change_column :invitations, :creator_id, :integer
    change_column :invitations, :updater_id, :integer
    change_column :invitations, :tenant_id, :integer
    change_column :invoices, :id, :integer
    change_column :invoices, :provider_account_id, :integer
    change_column :invoices, :buyer_account_id, :integer
    change_column :invoices, :tenant_id, :integer
    change_column :legal_term_acceptances, :id, :integer
    change_column :legal_term_acceptances, :legal_term_id, :integer
    change_column :legal_term_acceptances, :resource_id, :integer
    change_column :legal_term_acceptances, :tenant_id, :integer
    change_column :legal_term_acceptances, :account_id, :integer
    change_column :legal_term_bindings, :id, :integer
    change_column :legal_term_bindings, :legal_term_id, :integer
    change_column :legal_term_bindings, :resource_id, :integer
    change_column :legal_term_bindings, :tenant_id, :integer
    change_column :legal_term_versions, :id, :integer
    change_column :legal_term_versions, :legal_term_id, :integer
    change_column :legal_term_versions, :created_by_id, :integer
    change_column :legal_term_versions, :updated_by_id, :integer
    change_column :legal_term_versions, :tenant_id, :integer
    change_column :legal_terms, :id, :integer
    change_column :legal_terms, :created_by_id, :integer
    change_column :legal_terms, :updated_by_id, :integer
    change_column :legal_terms, :account_id, :integer
    change_column :legal_terms, :tenant_id, :integer
    change_column :line_items, :id, :integer
    change_column :line_items, :invoice_id, :integer
    change_column :line_items, :cinstance_id, :integer
    change_column :line_items, :metric_id, :integer
    change_column :line_items, :tenant_id, :integer
    change_column :link_versions, :id, :integer
    change_column :link_versions, :link_id, :integer
    change_column :link_versions, :created_by_id, :integer
    change_column :link_versions, :updated_by_id, :integer
    change_column :link_versions, :tenant_id, :integer
    change_column :links, :id, :integer
    change_column :links, :created_by_id, :integer
    change_column :links, :updated_by_id, :integer
    change_column :links, :account_id, :integer
    change_column :links, :tenant_id, :integer
    change_column :mail_dispatch_rules, :id, :integer
    change_column :mail_dispatch_rules, :account_id, :integer
    change_column :mail_dispatch_rules, :tenant_id, :integer
    change_column :message_recipients, :id, :integer
    change_column :message_recipients, :message_id, :integer
    change_column :message_recipients, :receiver_id, :integer
    change_column :message_recipients, :tenant_id, :integer
    change_column :messages, :id, :integer
    change_column :messages, :sender_id, :integer
    change_column :messages, :tenant_id, :integer
    change_column :metrics, :id, :integer
    change_column :metrics, :service_id, :integer
    change_column :metrics, :parent_id, :integer
    change_column :metrics, :tenant_id, :integer
    change_column :moderatorships, :id, :integer
    change_column :moderatorships, :forum_id, :integer
    change_column :moderatorships, :user_id, :integer
    change_column :moderatorships, :tenant_id, :integer
    change_column :page_route_options, :id, :integer
    change_column :page_route_options, :page_route_id, :integer
    change_column :page_route_options, :tenant_id, :integer
    change_column :page_routes, :id, :integer
    change_column :page_routes, :page_id, :integer
    change_column :page_routes, :tenant_id, :integer
    change_column :page_versions, :id, :integer
    change_column :page_versions, :page_id, :integer
    change_column :page_versions, :created_by_id, :integer
    change_column :page_versions, :updated_by_id, :integer
    change_column :page_versions, :tenant_id, :integer
    change_column :pages, :id, :integer
    change_column :pages, :created_by_id, :integer
    change_column :pages, :updated_by_id, :integer
    change_column :pages, :account_id, :integer
    change_column :pages, :tenant_id, :integer
    change_column :payment_transactions, :id, :integer
    change_column :payment_transactions, :account_id, :integer
    change_column :payment_transactions, :invoice_id, :integer
    change_column :payment_transactions, :tenant_id, :integer
    change_column :plan_metrics, :id, :integer
    change_column :plan_metrics, :plan_id, :integer
    change_column :plan_metrics, :metric_id, :integer
    change_column :plan_metrics, :tenant_id, :integer
    change_column :plans, :id, :integer
    change_column :plans, :issuer_id, :integer
    change_column :plans, :original_id, :integer
    change_column :plans, :tenant_id, :integer
    change_column :portlet_attributes, :id, :integer
    change_column :portlet_attributes, :portlet_id, :integer
    change_column :portlet_attributes, :tenant_id, :integer
    change_column :portlets, :id, :integer
    change_column :portlets, :created_by_id, :integer
    change_column :portlets, :updated_by_id, :integer
    change_column :portlets, :account_id, :integer
    change_column :portlets, :tenant_id, :integer
    change_column :posts, :id, :integer
    change_column :posts, :user_id, :integer
    change_column :posts, :topic_id, :integer
    change_column :posts, :forum_id, :integer
    change_column :posts, :tenant_id, :integer
    change_column :pricing_rules, :id, :integer
    change_column :pricing_rules, :metric_id, :integer
    change_column :pricing_rules, :plan_id, :integer
    change_column :pricing_rules, :tenant_id, :integer
    change_column :profiles, :id, :integer
    change_column :profiles, :account_id, :integer
    change_column :profiles, :tenant_id, :integer
    change_column :redirects, :id, :integer
    change_column :redirects, :account_id, :integer
    change_column :redirects, :tenant_id, :integer
    change_column :section_nodes, :id, :integer
    change_column :section_nodes, :section_id, :integer
    change_column :section_nodes, :node_id, :integer
    change_column :section_nodes, :account_id, :integer
    change_column :section_nodes, :tenant_id, :integer
    change_column :sections, :id, :integer
    change_column :sections, :account_id, :integer
    change_column :sections, :tenant_id, :integer
    change_column :services, :id, :integer
    change_column :services, :account_id, :integer
    change_column :services, :default_application_plan_id, :integer
    change_column :services, :default_service_plan_id, :integer
    change_column :services, :default_end_user_plan_id, :integer
    change_column :services, :tenant_id, :integer
    change_column :settings, :id, :integer
    change_column :settings, :account_id, :integer
    change_column :settings, :tenant_id, :integer
    change_column :slugs, :id, :integer
    change_column :slugs, :sluggable_id, :integer
    change_column :slugs, :tenant_id, :integer
    change_column :taggings, :id, :integer
    change_column :taggings, :tag_id, :integer
    change_column :taggings, :taggable_id, :integer
    change_column :taggings, :tenant_id, :integer
    change_column :tags, :id, :integer
    change_column :tags, :account_id, :integer
    change_column :tags, :tenant_id, :integer
    change_column :topic_categories, :id, :integer
    change_column :topic_categories, :forum_id, :integer
    change_column :topic_categories, :tenant_id, :integer
    change_column :topics, :id, :integer
    change_column :topics, :forum_id, :integer
    change_column :topics, :user_id, :integer
    change_column :topics, :last_post_id, :integer
    change_column :topics, :last_user_id, :integer
    change_column :topics, :category_id, :integer
    change_column :topics, :tenant_id, :integer
    change_column :usage_limits, :id, :integer
    change_column :usage_limits, :metric_id, :integer
    change_column :usage_limits, :plan_id, :integer
    change_column :usage_limits, :tenant_id, :integer
    change_column :user_group_memberships, :id, :integer
    change_column :user_group_memberships, :user_id, :integer
    change_column :user_group_memberships, :group_id, :integer
    change_column :user_group_memberships, :tenant_id, :integer
    change_column :user_topics, :id, :integer
    change_column :user_topics, :user_id, :integer
    change_column :user_topics, :topic_id, :integer
    change_column :user_topics, :tenant_id, :integer
    change_column :users, :id, :integer
    change_column :users, :account_id, :integer
    change_column :users, :tenant_id, :integer
    change_column :web_hooks, :id, :integer
    change_column :web_hooks, :account_id, :integer
    change_column :web_hooks, :tenant_id, :integer
    change_column :wiki_pages, :id, :integer
    change_column :wiki_pages, :account_id, :integer
    change_column :wiki_pages, :tenant_id, :integer
  end
end
