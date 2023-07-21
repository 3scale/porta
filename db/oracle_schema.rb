# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_07_21_123200) do

  create_table "access_tokens", force: :cascade do |t|
    t.integer "owner_id", precision: 38, null: false
    t.text "scopes"
    t.string "value", null: false
    t.string "name", null: false
    t.string "permission", null: false
    t.integer "tenant_id", precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "accounts", force: :cascade do |t|
    t.string "org_name", default: "", null: false
    t.string "org_legaladdress", default: ""
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6
    t.boolean "provider", default: false
    t.boolean "buyer", default: false
    t.integer "country_id", precision: 38
    t.integer "provider_account_id", precision: 38
    t.string "domain"
    t.string "telephone_number"
    t.string "site_access_code"
    t.string "credit_card_partial_number", limit: 4
    t.date "credit_card_expires_on"
    t.string "credit_card_auth_code"
    t.boolean "master"
    t.string "billing_address_name"
    t.string "billing_address_address1"
    t.string "billing_address_address2"
    t.string "billing_address_city"
    t.string "billing_address_state"
    t.string "billing_address_country"
    t.string "billing_address_zip"
    t.string "billing_address_phone"
    t.string "org_legaladdress_cont"
    t.string "city"
    t.string "state_region"
    t.string "state"
    t.boolean "paid", default: false
    t.datetime "paid_at", precision: 6
    t.boolean "signs_legal_terms", default: true
    t.string "timezone"
    t.boolean "delta", default: true, null: false
    t.string "from_email"
    t.string "primary_business"
    t.string "business_category"
    t.string "zip"
    t.text "extra_fields"
    t.string "vat_code"
    t.string "fiscal_code"
    t.decimal "vat_rate", precision: 20, scale: 2
    t.text "invoice_footnote"
    t.text "vat_zero_text"
    t.integer "default_account_plan_id", precision: 38
    t.integer "default_service_id", precision: 38
    t.string "credit_card_authorize_net_payment_profile_token"
    t.integer "tenant_id", precision: 38
    t.string "self_domain"
    t.string "s3_prefix"
    t.integer "prepared_assets_version", precision: 38
    t.boolean "sample_data"
    t.integer "proxy_configs_file_size", precision: 38
    t.datetime "proxy_configs_updated_at", precision: 6
    t.string "proxy_configs_content_type"
    t.string "proxy_configs_file_name"
    t.string "support_email"
    t.string "finance_support_email"
    t.string "billing_address_first_name"
    t.string "billing_address_last_name"
    t.boolean "email_all_users", default: false
    t.integer "partner_id", precision: 38
    t.string "proxy_configs_conf_file_name"
    t.string "proxy_configs_conf_content_type"
    t.integer "proxy_configs_conf_file_size", precision: 38
    t.datetime "proxy_configs_conf_updated_at", precision: 6
    t.datetime "hosted_proxy_deployed_at", precision: 6
    t.string "po_number"
    t.datetime "state_changed_at", precision: 6
    t.index ["default_service_id"], name: "index_accounts_on_default_service_id"
    t.index ["domain", "state_changed_at"], name: "index_accounts_on_domain_and_state_changed_at"
    t.index ["domain"], name: "index_accounts_on_domain", unique: true
    t.index ["master"], name: "index_accounts_on_master", unique: true
    t.index ["provider_account_id", "created_at"], name: "index_accounts_on_provider_account_id_and_created_at"
    t.index ["provider_account_id", "state"], name: "index_accounts_on_provider_account_id_and_state"
    t.index ["provider_account_id"], name: "index_accounts_on_provider_account_id"
    t.index ["self_domain", "state_changed_at"], name: "index_accounts_on_self_domain_and_state_changed_at"
    t.index ["self_domain"], name: "index_accounts_on_self_domain", unique: true
    t.index ["state", "state_changed_at"], name: "index_accounts_on_state_and_state_changed_at"
  end

  create_table "alerts", force: :cascade do |t|
    t.integer "account_id", precision: 38, null: false
    t.datetime "timestamp", precision: 6, null: false
    t.string "state", null: false
    t.integer "cinstance_id", precision: 38, null: false
    t.decimal "utilization", precision: 6, scale: 2, null: false
    t.integer "level", precision: 38, null: false
    t.integer "alert_id", precision: 38, null: false
    t.text "message"
    t.integer "tenant_id", precision: 38
    t.integer "service_id", precision: 38
    t.index ["account_id", "service_id", "state", "cinstance_id"], name: "index_alerts_with_service_id"
    t.index ["alert_id", "account_id"], name: "index_alerts_on_alert_id_and_account_id", unique: true
    t.index ["cinstance_id"], name: "index_alerts_on_cinstance_id"
    t.index ["timestamp"], name: "index_alerts_on_timestamp"
  end

  create_table "api_docs_services", force: :cascade do |t|
    t.integer "account_id", precision: 38
    t.integer "tenant_id", precision: 38
    t.string "name"
    t.text "body"
    t.text "description"
    t.boolean "published", default: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "system_name"
    t.string "base_path"
    t.string "swagger_version"
    t.boolean "skip_swagger_validations", default: false
    t.integer "service_id", precision: 38
    t.boolean "discovered"
    t.index ["account_id"], name: "index_api_docs_services_on_account_id"
    t.index ["service_id"], name: "index_api_docs_services_on_service_id"
  end

  create_table "application_keys", force: :cascade do |t|
    t.integer "application_id", precision: 38, null: false
    t.string "value", null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.index ["application_id", "value"], name: "index_application_keys_on_application_id_and_value", unique: true
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id", precision: 38
    t.string "auditable_type"
    t.integer "user_id", precision: 38
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.integer "version", precision: 38, default: 0
    t.datetime "created_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.integer "provider_id", precision: 38
    t.string "kind"
    t.text "audited_changes"
    t.text "comment"
    t.integer "associated_id", precision: 38
    t.string "associated_type"
    t.string "remote_address"
    t.string "request_uuid"
    t.index ["action"], name: "index_audits_on_action"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_id", "auditable_type", "version"], name: "index_audits_on_auditable_id_and_auditable_type_and_version"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["kind"], name: "index_audits_on_kind"
    t.index ["provider_id"], name: "index_audits_on_provider_id"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
    t.index ["version"], name: "index_audits_on_version"
  end

  create_table "authentication_providers", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.string "client_id"
    t.string "client_secret"
    t.string "token_url"
    t.string "user_info_url"
    t.string "authorize_url"
    t.string "site"
    t.integer "account_id", precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.string "identifier_key", default: "id"
    t.string "username_key", default: "login"
    t.boolean "trust_email", default: false
    t.string "kind"
    t.boolean "published", default: false
    t.string "branding_state"
    t.string "type"
    t.boolean "skip_ssl_certificate_verification", default: false
    t.string "account_type", default: "developer", null: false
    t.boolean "automatically_approve_accounts", default: false
    t.index ["account_id", "system_name"], name: "index_authentication_providers_on_account_id_and_system_name", unique: true
    t.index ["account_id"], name: "index_authentication_providers_on_account_id"
  end

  create_table "backend_api_configs", force: :cascade do |t|
    t.string "path", default: ""
    t.integer "service_id", precision: 38
    t.integer "backend_api_id", precision: 38
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "tenant_id", precision: 38
    t.index ["backend_api_id", "service_id"], name: "index_backend_api_configs_on_backend_api_id_and_service_id", unique: true
    t.index ["path", "service_id"], name: "index_backend_api_configs_on_path_and_service_id", unique: true
    t.index ["service_id"], name: "index_backend_api_configs_on_service_id"
  end

  create_table "backend_apis", force: :cascade do |t|
    t.string "name", limit: 511, null: false
    t.string "system_name", null: false
    t.text "description"
    t.string "private_endpoint"
    t.integer "account_id", precision: 38
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "tenant_id", precision: 38
    t.string "state", default: "published", null: false
    t.index ["account_id", "system_name"], name: "index_backend_apis_on_account_id_and_system_name", unique: true
    t.index ["state"], name: "index_backend_apis_on_state"
  end

  create_table "backend_events", id: false, force: :cascade do |t|
    t.integer "id", precision: 38, null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["id"], name: "index_backend_events_on_id", unique: true
  end

  create_table "billing_locks", primary_key: "account_id", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
  end

  create_table "billing_strategies", force: :cascade do |t|
    t.integer "account_id", precision: 38
    t.boolean "prepaid", default: false
    t.boolean "charging_enabled", default: false
    t.integer "charging_retry_delay", precision: 38, default: 3
    t.integer "charging_retry_times", precision: 38, default: 3
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "numbering_period", default: "monthly"
    t.string "currency", default: "USD"
    t.integer "tenant_id", precision: 38
    t.string "type"
    t.index ["account_id"], name: "index_billing_strategies_on_account_id"
  end

  create_table "categories", force: :cascade do |t|
    t.integer "category_type_id", precision: 38
    t.integer "parent_id", precision: 38
    t.string "name"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "account_id", precision: 38
    t.integer "tenant_id", precision: 38
    t.index ["account_id"], name: "index_categories_on_account_id"
  end

  create_table "category_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "account_id", precision: 38
    t.integer "tenant_id", precision: 38
    t.index ["account_id"], name: "index_category_types_on_account_id"
  end

  create_table "cinstances", force: :cascade do |t|
    t.integer "plan_id", precision: 38, null: false
    t.integer "user_account_id", precision: 38
    t.string "user_key", limit: 256
    t.string "provider_public_key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6
    t.string "state", null: false
    t.text "description"
    t.datetime "paid_until", precision: 6
    t.string "application_id"
    t.string "name"
    t.datetime "trial_period_expires_at", precision: 6
    t.decimal "setup_fee", precision: 20, scale: 2, default: "0.0"
    t.string "type", default: "Cinstance", null: false
    t.text "redirect_url"
    t.datetime "variable_cost_paid_until", precision: 6
    t.text "extra_fields"
    t.integer "tenant_id", precision: 38
    t.string "create_origin"
    t.datetime "first_traffic_at", precision: 6
    t.datetime "first_daily_traffic_at", precision: 6
    t.integer "service_id", precision: 38
    t.datetime "accepted_at", precision: 6
    t.index ["application_id"], name: "index_cinstances_on_application_id"
    t.index ["plan_id"], name: "fk_ct_contract_id"
    t.index ["type", "plan_id", "service_id", "state"], name: "index_cinstances_on_type_and_plan_id_and_service_id_and_state"
    t.index ["type", "service_id", "created_at"], name: "index_cinstances_on_type_and_service_id_and_created_at"
    t.index ["type", "service_id", "plan_id", "state"], name: "index_cinstances_on_type_and_service_id_and_plan_id_and_state"
    t.index ["type", "service_id", "state", "first_traffic_at"], name: "idx_cinstances_service_state_traffic"
    t.index ["user_account_id"], name: "fk_ct_user_account_id"
    t.index ["user_key"], name: "index_cinstances_on_user_key"
  end

  create_table "cms_files", force: :cascade do |t|
    t.integer "provider_id", precision: 38, null: false
    t.integer "section_id", precision: 38
    t.integer "tenant_id", precision: 38
    t.datetime "attachment_updated_at", precision: 6
    t.string "attachment_content_type"
    t.integer "attachment_file_size", precision: 38
    t.string "attachment_file_name"
    t.string "random_secret"
    t.string "path"
    t.boolean "downloadable"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["provider_id", "path"], name: "index_cms_files_on_provider_id_and_path"
    t.index ["provider_id"], name: "index_cms_files_on_provider_id"
    t.index ["section_id"], name: "index_cms_files_on_section_id"
  end

  create_table "cms_group_sections", force: :cascade do |t|
    t.integer "group_id", precision: 38
    t.integer "section_id", precision: 38
    t.integer "tenant_id", precision: 38
    t.index ["group_id"], name: "index_cms_group_sections_on_group_id"
  end

  create_table "cms_groups", force: :cascade do |t|
    t.integer "tenant_id", precision: 38
    t.integer "provider_id", precision: 38, null: false
    t.string "name"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["provider_id"], name: "index_cms_groups_on_provider_id"
  end

  create_table "cms_permissions", force: :cascade do |t|
    t.integer "tenant_id", precision: 38
    t.integer "account_id", precision: 38
    t.string "name"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "group_id", precision: 38
    t.index ["account_id"], name: "index_cms_permissions_on_account_id"
  end

  create_table "cms_redirects", force: :cascade do |t|
    t.integer "provider_id", precision: 38, null: false
    t.string "source", null: false
    t.string "target", null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.index ["provider_id", "source"], name: "index_cms_redirects_on_provider_id_and_source"
    t.index ["provider_id"], name: "index_cms_redirects_on_provider_id"
  end

  create_table "cms_sections", force: :cascade do |t|
    t.integer "provider_id", precision: 38, null: false
    t.integer "tenant_id", precision: 38
    t.integer "parent_id", precision: 38
    t.string "partial_path"
    t.string "title"
    t.string "system_name"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.boolean "public", default: true
    t.string "type", default: "CMS::Section"
    t.index ["parent_id"], name: "index_cms_sections_on_parent_id"
    t.index ["provider_id"], name: "index_cms_sections_on_provider_id"
  end

  create_table "cms_templates", force: :cascade do |t|
    t.integer "provider_id", precision: 38, null: false
    t.integer "tenant_id", precision: 38
    t.integer "section_id", precision: 38
    t.string "type"
    t.string "path"
    t.string "title"
    t.string "system_name"
    t.text "published"
    t.text "draft"
    t.boolean "liquid_enabled"
    t.string "content_type"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "layout_id", precision: 38
    t.text "options"
    t.string "updated_by"
    t.string "handler"
    t.boolean "searchable", default: false
    t.string "rails_view_path"
    t.index ["provider_id", "path"], name: "index_cms_templates_on_provider_id_and_path"
    t.index ["provider_id", "rails_view_path"], name: "index_cms_templates_on_provider_id_and_rails_view_path"
    t.index ["provider_id", "system_name"], name: "index_cms_templates_on_provider_id_and_system_name"
    t.index ["provider_id", "type"], name: "index_cms_templates_on_provider_id_type"
    t.index ["section_id"], name: "index_cms_templates_on_section_id"
    t.index ["type"], name: "index_cms_templates_on_type"
  end

  create_table "cms_templates_versions", force: :cascade do |t|
    t.integer "provider_id", precision: 38, null: false
    t.integer "tenant_id", precision: 38
    t.integer "section_id", precision: 38
    t.string "type"
    t.string "path"
    t.string "title"
    t.string "system_name"
    t.text "published"
    t.text "draft"
    t.boolean "liquid_enabled"
    t.string "content_type"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "layout_id", precision: 38
    t.integer "template_id", precision: 38
    t.string "template_type"
    t.text "options"
    t.string "updated_by"
    t.string "handler"
    t.boolean "searchable", default: false
    t.index ["provider_id", "type"], name: "index_cms_templates_versions_on_provider_id_type"
    t.index ["template_id", "template_type"], name: "by_template"
  end

  create_table "configuration_values", force: :cascade do |t|
    t.integer "configurable_id", precision: 38
    t.string "configurable_type", limit: 50
    t.string "name"
    t.string "value"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.index ["configurable_id", "configurable_type", "name"], name: "index_on_configurable_and_name", unique: true
    t.index ["configurable_id", "configurable_type"], name: "index_on_configurable"
  end

  create_table "countries", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "currency"
    t.decimal "tax_rate", precision: 5, scale: 2, default: "0.0", null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.boolean "enabled", default: true
    t.index ["code"], name: "index_countries_on_code"
  end

  create_table "deleted_objects", force: :cascade do |t|
    t.integer "owner_id", precision: 38
    t.string "owner_type"
    t.integer "object_id", precision: 38
    t.string "object_type"
    t.datetime "created_at", precision: 6, null: false
    t.text "metadata"
    t.index ["object_type", "object_id"], name: "index_deleted_objects_on_object_type_and_object_id"
    t.index ["owner_type", "owner_id"], name: "index_deleted_objects_on_owner_type_and_owner_id"
  end

  create_table "email_configurations", force: :cascade do |t|
    t.integer "account_id", precision: 38
    t.string "email", null: false
    t.string "domain"
    t.string "user_name"
    t.string "password"
    t.string "authentication"
    t.string "tls"
    t.string "openssl_verify_mode"
    t.string "address"
    t.integer "port", precision: 38
    t.integer "tenant_id", precision: 38
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_email_configurations_on_account_id"
    t.index ["email"], name: "index_email_configurations_on_email", unique: true
  end

  create_table "event_store_events", force: :cascade do |t|
    t.string "stream", null: false
    t.string "event_type", null: false
    t.string "event_id", null: false
    t.text "metadata"
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.integer "provider_id", precision: 38
    t.integer "tenant_id", precision: 38
    t.index ["created_at"], name: "index_event_store_events_on_created_at"
    t.index ["event_id"], name: "index_event_store_events_on_event_id", unique: true
    t.index ["provider_id"], name: "index_event_store_events_on_provider_id"
    t.index ["stream"], name: "index_event_store_events_on_stream"
  end

  create_table "features", force: :cascade do |t|
    t.integer "featurable_id", precision: 38
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "system_name"
    t.boolean "visible", default: true, null: false
    t.string "featurable_type", default: "Service", null: false
    t.string "scope", default: "ApplicationPlan", null: false
    t.integer "tenant_id", precision: 38
    t.index ["featurable_type", "featurable_id"], name: "index_features_on_featurable_type_and_featurable_id"
    t.index ["featurable_type"], name: "index_features_on_featurable_type"
    t.index ["scope"], name: "index_features_on_scope"
    t.index ["system_name"], name: "index_features_on_system_name"
  end

  create_table "features_plans", id: false, force: :cascade do |t|
    t.integer "plan_id", precision: 38
    t.integer "feature_id", precision: 38
    t.string "plan_type", null: false
    t.integer "tenant_id", precision: 38
    t.index ["plan_id", "feature_id"], name: "index_features_plans_on_plan_id_and_feature_id"
  end

  create_table "fields_definitions", force: :cascade do |t|
    t.integer "account_id", precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "target"
    t.boolean "hidden", default: false
    t.boolean "required", default: false
    t.string "label"
    t.string "name"
    t.text "choices"
    t.text "hint"
    t.boolean "read_only", default: false
    t.integer "pos", precision: 38
    t.integer "tenant_id", precision: 38
    t.index ["account_id"], name: "index_fields_definitions_on_account_id"
  end

  create_table "forums", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "topics_count", precision: 38, default: 0
    t.integer "posts_count", precision: 38, default: 0
    t.integer "position", precision: 38, default: 0
    t.text "description_html"
    t.string "state", default: "public"
    t.string "permalink"
    t.integer "account_id", precision: 38
    t.integer "tenant_id", precision: 38
    t.index ["permalink"], name: "index_forums_on_site_id_and_permalink"
    t.index ["position"], name: "index_forums_on_position_and_site_id"
  end

  create_table "gateway_configurations", force: :cascade do |t|
    t.text "settings"
    t.integer "proxy_id", precision: 38
    t.integer "tenant_id", precision: 38
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["proxy_id"], name: "index_gateway_configurations_on_proxy_id", unique: true
  end

  create_table "go_live_states", force: :cascade do |t|
    t.integer "account_id", precision: 38
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "steps"
    t.string "recent"
    t.boolean "finished", default: false
    t.integer "tenant_id", precision: 38
    t.index ["account_id"], name: "index_go_live_states_on_account_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.string "token"
    t.string "email"
    t.datetime "sent_at", precision: 6
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "account_id", precision: 38
    t.datetime "accepted_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.integer "user_id", precision: 38
  end

  create_table "invoice_counters", force: :cascade do |t|
    t.integer "provider_account_id", precision: 38, null: false
    t.string "invoice_prefix", null: false
    t.integer "invoice_count", precision: 38, default: 0
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["provider_account_id", "invoice_prefix"], name: "index_invoice_counters_provider_prefix", unique: true
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "provider_account_id", precision: 38
    t.integer "buyer_account_id", precision: 38
    t.datetime "paid_at", precision: 6
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.date "due_on"
    t.string "pdf_file_name"
    t.string "pdf_content_type"
    t.integer "pdf_file_size", precision: 38
    t.datetime "pdf_updated_at", precision: 6
    t.date "period"
    t.date "issued_on"
    t.string "state", default: "open", null: false
    t.string "friendly_id", default: "fix", null: false
    t.integer "tenant_id", precision: 38
    t.datetime "finalized_at", precision: 6
    t.string "fiscal_code"
    t.string "vat_code"
    t.decimal "vat_rate", precision: 20, scale: 2
    t.string "currency", limit: 4
    t.string "from_address_name"
    t.string "from_address_line1"
    t.string "from_address_line2"
    t.string "from_address_city"
    t.string "from_address_region"
    t.string "from_address_state"
    t.string "from_address_country"
    t.string "from_address_zip"
    t.string "from_address_phone"
    t.string "to_address_name"
    t.string "to_address_line1"
    t.string "to_address_line2"
    t.string "to_address_city"
    t.string "to_address_region"
    t.string "to_address_state"
    t.string "to_address_country"
    t.string "to_address_zip"
    t.string "to_address_phone"
    t.integer "charging_retries_count", precision: 38, default: 0, null: false
    t.date "last_charging_retry"
    t.string "creation_type", default: "manual"
    t.index ["buyer_account_id", "state"], name: "index_invoices_on_buyer_account_id_and_state"
    t.index ["buyer_account_id"], name: "index_invoices_on_buyer_account_id"
    t.index ["provider_account_id", "buyer_account_id"], name: "index_invoices_on_provider_account_id_and_buyer_account_id"
    t.index ["provider_account_id"], name: "index_invoices_on_provider_account_id"
  end

  create_table "legal_term_acceptances", force: :cascade do |t|
    t.integer "legal_term_id", precision: 38
    t.integer "legal_term_version", precision: 38
    t.string "resource_type"
    t.integer "resource_id", precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.integer "account_id", precision: 38
    t.index ["account_id"], name: "index_legal_term_acceptances_on_account_id"
  end

  create_table "legal_term_bindings", force: :cascade do |t|
    t.integer "legal_term_id", precision: 38
    t.integer "legal_term_version", precision: 38
    t.string "resource_type"
    t.integer "resource_id", precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "scope"
    t.integer "tenant_id", precision: 38
  end

  create_table "legal_term_versions", force: :cascade do |t|
    t.integer "legal_term_id", precision: 38
    t.integer "version", precision: 38
    t.string "name"
    t.string "slug"
    t.text "body"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.boolean "published", default: false
    t.boolean "deleted", default: false
    t.boolean "archived", default: false
    t.string "version_comment"
    t.integer "created_by_id", precision: 38
    t.integer "updated_by_id", precision: 38
    t.integer "tenant_id", precision: 38
  end

  create_table "legal_terms", force: :cascade do |t|
    t.integer "version", precision: 38
    t.integer "lock_version", precision: 38, default: 0
    t.string "name"
    t.string "slug"
    t.text "body"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.boolean "published", default: false
    t.boolean "deleted", default: false
    t.boolean "archived", default: false
    t.integer "created_by_id", precision: 38
    t.integer "updated_by_id", precision: 38
    t.integer "account_id", precision: 38
    t.integer "tenant_id", precision: 38
    t.index ["account_id"], name: "index_legal_terms_on_account_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.integer "invoice_id", precision: 38
    t.string "name"
    t.string "description"
    t.decimal "cost", precision: 20, scale: 4, default: "0.0", null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "type", default: ""
    t.integer "metric_id", precision: 38
    t.datetime "finished_at", precision: 6
    t.integer "quantity", precision: 38
    t.date "started_at"
    t.integer "tenant_id", precision: 38
    t.integer "contract_id", precision: 38
    t.string "contract_type"
    t.integer "cinstance_id", precision: 38
    t.integer "plan_id", precision: 38
    t.index ["invoice_id"], name: "index_line_items_on_invoice_id"
  end

  create_table "log_entries", force: :cascade do |t|
    t.integer "tenant_id", precision: 38
    t.integer "provider_id", precision: 38
    t.integer "buyer_id", precision: 38
    t.integer "level", precision: 38, default: 10
    t.string "description"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["provider_id"], name: "index_log_entries_on_provider_id"
  end

  create_table "mail_dispatch_rules", force: :cascade do |t|
    t.integer "account_id", precision: 38
    t.integer "system_operation_id", precision: 38
    t.text "emails"
    t.boolean "dispatch", default: true
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.index ["account_id", "system_operation_id"], name: "index_mail_dispatch_rules_on_account_id_and_system_operation_id", unique: true
  end

  create_table "member_permissions", force: :cascade do |t|
    t.integer "user_id", precision: 38
    t.string "admin_section"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.binary "service_ids"
    t.index ["user_id"], name: "index_member_permissions_on_user_id"
  end

  create_table "message_recipients", force: :cascade do |t|
    t.integer "message_id", precision: 38, null: false
    t.integer "receiver_id", precision: 38, null: false
    t.string "receiver_type", default: "", null: false
    t.string "kind", default: "", null: false
    t.integer "position", precision: 38
    t.string "state", null: false
    t.datetime "hidden_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.datetime "deleted_at", precision: 6
    t.index ["message_id", "kind"], name: "index_message_recipients_on_message_id_and_kind"
    t.index ["receiver_id"], name: "idx_receiver_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "sender_id", precision: 38, null: false
    t.text "subject"
    t.text "body"
    t.string "state", null: false
    t.datetime "hidden_at", precision: 6
    t.string "type"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "system_operation_id", precision: 38
    t.text "headers"
    t.integer "tenant_id", precision: 38
    t.string "origin"
    t.index ["sender_id", "hidden_at"], name: "index_messages_on_sender_id_and_hidden_at"
  end

  create_table "metrics", force: :cascade do |t|
    t.string "system_name"
    t.text "description"
    t.string "unit"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6
    t.integer "service_id", precision: 38
    t.string "friendly_name"
    t.integer "parent_id", precision: 38
    t.integer "tenant_id", precision: 38
    t.integer "owner_id", precision: 38
    t.string "owner_type"
    t.index ["owner_type", "owner_id", "system_name"], name: "index_metrics_on_owner_type_and_owner_id_and_system_name", unique: true
    t.index ["owner_type", "owner_id"], name: "index_metrics_on_owner_type_and_owner_id"
    t.index ["parent_id"], name: "index_metrics_on_parent_id"
    t.index ["service_id", "system_name"], name: "index_metrics_on_service_id_and_system_name", unique: true
    t.index ["service_id"], name: "index_metrics_on_service_id"
  end

  create_table "moderatorships", force: :cascade do |t|
    t.integer "forum_id", precision: 38
    t.integer "user_id", precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "tenant_id", precision: 38
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.integer "user_id", precision: 38
    t.binary "preferences"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.index ["user_id"], name: "index_notification_preferences_on_user_id", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", precision: 38
    t.string "event_id", null: false
    t.string "system_name", limit: 1000
    t.string "state", limit: 20
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "title", limit: 1000
    t.index ["event_id"], name: "index_notifications_on_event_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "oidc_configurations", force: :cascade do |t|
    t.text "config"
    t.string "oidc_configurable_type", null: false
    t.integer "oidc_configurable_id", precision: 38, null: false
    t.integer "tenant_id", precision: 38
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["oidc_configurable_type", "oidc_configurable_id"], name: "oidc_configurable", unique: true
  end

  create_table "onboardings", force: :cascade do |t|
    t.integer "account_id", precision: 38
    t.string "wizard_state"
    t.string "bubble_api_state"
    t.string "bubble_metric_state"
    t.string "bubble_deployment_state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "bubble_mapping_state"
    t.string "bubble_limit_state"
    t.integer "tenant_id", precision: 38
    t.index ["account_id"], name: "index_onboardings_on_account_id"
  end

  create_table "partners", force: :cascade do |t|
    t.string "name"
    t.string "api_key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "system_name"
    t.string "logout_url"
  end

  create_table "payment_details", force: :cascade do |t|
    t.integer "account_id", precision: 38
    t.string "buyer_reference"
    t.string "payment_service_reference"
    t.string "credit_card_partial_number"
    t.date "credit_card_expires_on"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "tenant_id", precision: 38
    t.string "payment_method_id"
    t.index ["account_id", "buyer_reference"], name: "index_payment_details_on_account_id_and_buyer_reference"
    t.index ["account_id", "payment_service_reference"], name: "index_payment_details_on_account_id_and_payment_ref"
    t.index ["account_id"], name: "index_payment_details_on_account_id"
  end

  create_table "payment_gateway_settings", force: :cascade do |t|
    t.binary "gateway_settings"
    t.string "gateway_type"
    t.integer "account_id", precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.index ["account_id"], name: "index_payment_gateway_settings_on_account_id"
  end

  create_table "payment_intents", force: :cascade do |t|
    t.integer "invoice_id", precision: 38, null: false
    t.string "state"
    t.integer "tenant_id", precision: 38
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "reference"
    t.index ["invoice_id"], name: "index_payment_intents_on_invoice_id"
    t.index ["reference"], name: "index_payment_intents_on_reference", unique: true
    t.index ["state"], name: "index_payment_intents_on_state"
  end

  create_table "payment_transactions", force: :cascade do |t|
    t.integer "account_id", precision: 38
    t.integer "invoice_id", precision: 38
    t.boolean "success", default: false, null: false
    t.decimal "amount", precision: 20, scale: 4
    t.string "currency", limit: 4, default: "EUR", null: false
    t.string "reference"
    t.string "message"
    t.string "action"
    t.text "params"
    t.boolean "test", default: false, null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "tenant_id", precision: 38
    t.index ["invoice_id"], name: "index_payment_transactions_on_invoice_id"
  end

