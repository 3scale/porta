# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_09_27_012615) do

  create_table "access_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.text "scopes"
    t.string "value", null: false
    t.string "name", null: false
    t.string "permission", null: false
    t.bigint "tenant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_id"], name: "idx_auth_tokens_of_user"
    t.index ["value", "owner_id"], name: "idx_value_auth_tokens_of_user", unique: true
  end

  create_table "accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "org_name", default: "", null: false
    t.string "org_legaladdress", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at"
    t.boolean "provider", default: false
    t.boolean "buyer", default: false
    t.bigint "country_id"
    t.bigint "provider_account_id"
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
    t.datetime "paid_at"
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
    t.bigint "default_account_plan_id"
    t.bigint "default_service_id"
    t.string "credit_card_authorize_net_payment_profile_token"
    t.bigint "tenant_id"
    t.string "self_domain"
    t.string "s3_prefix"
    t.integer "prepared_assets_version"
    t.boolean "sample_data"
    t.integer "proxy_configs_file_size"
    t.datetime "proxy_configs_updated_at"
    t.string "proxy_configs_content_type"
    t.string "proxy_configs_file_name"
    t.string "support_email"
    t.string "finance_support_email"
    t.string "billing_address_first_name"
    t.string "billing_address_last_name"
    t.boolean "email_all_users", default: false
    t.bigint "partner_id"
    t.string "proxy_configs_conf_file_name"
    t.string "proxy_configs_conf_content_type"
    t.integer "proxy_configs_conf_file_size"
    t.datetime "proxy_configs_conf_updated_at"
    t.datetime "hosted_proxy_deployed_at"
    t.string "po_number"
    t.datetime "state_changed_at"
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

  create_table "alerts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "timestamp", null: false
    t.string "state", null: false
    t.bigint "cinstance_id", null: false
    t.decimal "utilization", precision: 6, scale: 2, null: false
    t.integer "level", null: false
    t.bigint "alert_id", null: false
    t.text "message"
    t.bigint "tenant_id"
    t.bigint "service_id"
    t.index ["account_id", "service_id", "state", "cinstance_id"], name: "index_alerts_with_service_id"
    t.index ["alert_id", "account_id"], name: "index_alerts_on_alert_id_and_account_id", unique: true
    t.index ["cinstance_id"], name: "index_alerts_on_cinstance_id"
    t.index ["timestamp"], name: "index_alerts_on_timestamp"
  end

  create_table "api_docs_services", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "tenant_id"
    t.string "name"
    t.text "body", size: :long
    t.text "description"
    t.boolean "published", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "system_name"
    t.string "base_path"
    t.string "swagger_version"
    t.boolean "skip_swagger_validations", default: false
    t.bigint "service_id"
    t.boolean "discovered"
    t.index ["account_id"], name: "index_api_docs_services_on_account_id"
    t.index ["service_id"], name: "fk_rails_e4d18239f1"
  end

  create_table "application_keys", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.string "value", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
    t.index ["application_id", "value"], name: "index_application_keys_on_application_id_and_value", unique: true
  end

  create_table "audits", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "auditable_id"
    t.string "auditable_type"
    t.bigint "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.integer "version", default: 0
    t.datetime "created_at"
    t.bigint "tenant_id"
    t.bigint "provider_id"
    t.string "kind"
    t.text "audited_changes", size: :medium
    t.text "comment"
    t.integer "associated_id"
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

  create_table "authentication_providers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.string "client_id"
    t.string "client_secret"
    t.string "token_url"
    t.string "user_info_url"
    t.string "authorize_url"
    t.string "site"
    t.bigint "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
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

  create_table "backend_api_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "path", default: ""
    t.bigint "service_id"
    t.bigint "backend_api_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.index ["backend_api_id", "service_id"], name: "index_backend_api_configs_on_backend_api_id_and_service_id", unique: true
    t.index ["path", "service_id"], name: "index_backend_api_configs_on_path_and_service_id", unique: true
    t.index ["service_id"], name: "index_backend_api_configs_on_service_id"
  end

  create_table "backend_apis", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name", limit: 511, null: false
    t.string "system_name", null: false
    t.text "description", size: :medium
    t.string "private_endpoint"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.string "state", default: "published", null: false
    t.index ["account_id", "system_name"], name: "index_backend_apis_on_account_id_and_system_name", unique: true
    t.index ["state"], name: "index_backend_apis_on_state"
  end

  create_table "backend_events", id: :bigint, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "billing_strategies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "account_id"
    t.boolean "prepaid", default: false
    t.boolean "charging_enabled", default: false
    t.integer "charging_retry_delay", default: 3
    t.integer "charging_retry_times", default: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "numbering_period", default: "monthly"
    t.string "currency", default: "USD"
    t.bigint "tenant_id"
    t.string "type"
    t.index ["account_id"], name: "index_billing_strategies_on_account_id"
  end

  create_table "categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "category_type_id"
    t.bigint "parent_id"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "account_id"
    t.bigint "tenant_id"
    t.index ["account_id"], name: "index_categories_on_account_id"
  end

  create_table "category_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "account_id"
    t.bigint "tenant_id"
    t.index ["account_id"], name: "index_category_types_on_account_id"
  end

  create_table "cinstances", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.bigint "user_account_id"
    t.string "user_key", limit: 256
    t.string "provider_public_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at"
    t.string "state", null: false
    t.text "description"
    t.datetime "paid_until"
    t.string "application_id"
    t.string "name"
    t.datetime "trial_period_expires_at"
    t.decimal "setup_fee", precision: 20, scale: 2, default: "0.0"
    t.string "type", default: "Cinstance", null: false
    t.text "redirect_url"
    t.datetime "variable_cost_paid_until"
    t.text "extra_fields"
    t.bigint "tenant_id"
    t.string "create_origin"
    t.datetime "first_traffic_at"
    t.datetime "first_daily_traffic_at"
    t.bigint "service_id"
    t.datetime "accepted_at"
    t.index ["application_id"], name: "index_cinstances_on_application_id"
    t.index ["plan_id"], name: "fk_ct_contract_id"
    t.index ["type", "plan_id", "service_id", "state"], name: "index_cinstances_on_type_and_plan_id_and_service_id_and_state"
    t.index ["type", "service_id", "created_at"], name: "index_cinstances_on_type_and_service_id_and_created_at"
    t.index ["type", "service_id", "plan_id", "state"], name: "index_cinstances_on_type_and_service_id_and_plan_id_and_state"
    t.index ["type", "service_id", "state", "first_traffic_at"], name: "idx_cinstances_service_state_traffic"
    t.index ["user_account_id"], name: "fk_ct_user_account_id"
    t.index ["user_key"], name: "index_cinstances_on_user_key", length: 255
  end

  create_table "cms_files", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.bigint "section_id"
    t.bigint "tenant_id"
    t.datetime "attachment_updated_at"
    t.string "attachment_content_type"
    t.bigint "attachment_file_size"
    t.string "attachment_file_name"
    t.string "random_secret"
    t.string "path"
    t.boolean "downloadable"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["provider_id", "path"], name: "index_cms_files_on_provider_id_and_path"
    t.index ["provider_id"], name: "index_cms_files_on_provider_id"
    t.index ["section_id"], name: "index_cms_files_on_section_id"
  end

  create_table "cms_group_sections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "section_id"
    t.bigint "tenant_id"
    t.index ["group_id"], name: "index_cms_group_sections_on_group_id"
  end

  create_table "cms_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "tenant_id"
    t.bigint "provider_id", null: false
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["provider_id"], name: "index_cms_groups_on_provider_id"
  end

  create_table "cms_permissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "tenant_id"
    t.bigint "account_id"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "group_id"
    t.index ["account_id"], name: "index_cms_permissions_on_account_id"
  end

  create_table "cms_redirects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.string "source", null: false
    t.string "target", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
    t.index ["provider_id", "source"], name: "index_cms_redirects_on_provider_id_and_source"
    t.index ["provider_id"], name: "index_cms_redirects_on_provider_id"
  end

  create_table "cms_sections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.bigint "tenant_id"
    t.bigint "parent_id"
    t.string "partial_path"
    t.string "title"
    t.string "system_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "public", default: true
    t.string "type", default: "CMS::Section"
    t.index ["parent_id"], name: "index_cms_sections_on_parent_id"
    t.index ["provider_id"], name: "index_cms_sections_on_provider_id"
  end

  create_table "cms_templates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.bigint "tenant_id"
    t.bigint "section_id"
    t.string "type"
    t.string "path"
    t.string "title"
    t.string "system_name"
    t.text "published", size: :medium
    t.text "draft", size: :medium
    t.boolean "liquid_enabled"
    t.string "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "layout_id"
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

  create_table "cms_templates_versions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.bigint "tenant_id"
    t.bigint "section_id"
    t.string "type"
    t.string "path"
    t.string "title"
    t.string "system_name"
    t.text "published", size: :medium
    t.text "draft", size: :medium
    t.boolean "liquid_enabled"
    t.string "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "layout_id"
    t.bigint "template_id"
    t.string "template_type"
    t.text "options"
    t.string "updated_by"
    t.string "handler"
    t.boolean "searchable", default: false
    t.index ["provider_id", "type"], name: "index_cms_templates_versions_on_provider_id_type"
    t.index ["template_id", "template_type"], name: "by_template"
  end

  create_table "configuration_values", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "configurable_id"
    t.string "configurable_type", limit: 50
    t.string "name"
    t.string "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
    t.index ["configurable_id", "configurable_type", "name"], name: "index_on_configurable_and_name", unique: true
    t.index ["configurable_id", "configurable_type"], name: "index_on_configurable"
  end

  create_table "countries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "currency"
    t.decimal "tax_rate", precision: 5, scale: 2, default: "0.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "tenant_id"
    t.boolean "enabled", default: true
    t.index ["code"], name: "index_countries_on_code"
  end

  create_table "deleted_objects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "owner_id"
    t.string "owner_type"
    t.bigint "object_id"
    t.string "object_type"
    t.datetime "created_at", null: false
    t.text "metadata"
    t.index ["object_type", "object_id"], name: "index_deleted_objects_on_object_type_and_object_id"
    t.index ["owner_type", "owner_id"], name: "index_deleted_objects_on_owner_type_and_owner_id"
  end

  create_table "email_configurations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "account_id"
    t.string "email", null: false, collation: "utf8_general_ci"
    t.string "domain", collation: "utf8_general_ci"
    t.string "user_name"
    t.string "password"
    t.string "authentication"
    t.string "tls"
    t.string "openssl_verify_mode"
    t.string "address", collation: "utf8_general_ci"
    t.integer "port", limit: 2, unsigned: true
    t.bigint "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_email_configurations_on_account_id"
    t.index ["email"], name: "index_email_configurations_on_email", unique: true
  end

  create_table "event_store_events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "stream", null: false
    t.string "event_type", null: false
    t.string "event_id", null: false
    t.text "metadata", size: :medium
    t.text "data"
    t.datetime "created_at", null: false
    t.bigint "provider_id"
    t.bigint "tenant_id"
    t.index ["created_at"], name: "index_event_store_events_on_created_at"
    t.index ["event_id"], name: "index_event_store_events_on_event_id", unique: true
    t.index ["provider_id"], name: "index_event_store_events_on_provider_id"
    t.index ["stream"], name: "index_event_store_events_on_stream"
  end

  create_table "features", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "featurable_id"
    t.string "name"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "system_name"
    t.boolean "visible", default: true, null: false
    t.string "featurable_type", default: "Service", null: false
    t.string "scope", default: "ApplicationPlan", null: false
    t.bigint "tenant_id"
    t.index ["featurable_type", "featurable_id"], name: "index_features_on_featurable_type_and_featurable_id"
    t.index ["featurable_type"], name: "index_features_on_featurable_type"
    t.index ["scope"], name: "index_features_on_scope"
    t.index ["system_name"], name: "index_features_on_system_name"
  end

  create_table "features_plans", primary_key: ["plan_id", "feature_id"], options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.bigint "feature_id", null: false
    t.string "plan_type", null: false
    t.bigint "tenant_id"
  end

  create_table "fields_definitions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "target"
    t.boolean "hidden", default: false
    t.boolean "required", default: false
    t.string "label"
    t.string "name"
    t.text "choices"
    t.text "hint"
    t.boolean "read_only", default: false
    t.integer "pos"
    t.bigint "tenant_id"
    t.index ["account_id"], name: "index_fields_definitions_on_account_id"
  end

  create_table "forums", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "topics_count", default: 0
    t.integer "posts_count", default: 0
    t.integer "position", default: 0
    t.text "description_html"
    t.string "state", default: "public"
    t.string "permalink"
    t.bigint "account_id"
    t.bigint "tenant_id"
    t.index ["permalink"], name: "index_forums_on_site_id_and_permalink"
    t.index ["position"], name: "index_forums_on_position_and_site_id"
  end

  create_table "gateway_configurations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.text "settings"
    t.bigint "proxy_id"
    t.bigint "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proxy_id"], name: "index_gateway_configurations_on_proxy_id", unique: true
  end

  create_table "go_live_states", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "steps"
    t.string "recent"
    t.boolean "finished", default: false
    t.bigint "tenant_id"
    t.index ["account_id"], name: "index_go_live_states_on_account_id"
  end

  create_table "invitations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "token"
    t.string "email"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "account_id"
    t.datetime "accepted_at"
    t.bigint "tenant_id"
    t.bigint "user_id"
  end

  create_table "invoice_counters", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "provider_account_id", null: false
    t.string "invoice_prefix", null: false
    t.integer "invoice_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["provider_account_id", "invoice_prefix"], name: "index_invoice_counters_provider_prefix", unique: true
  end

  create_table "invoices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "provider_account_id"
    t.bigint "buyer_account_id"
    t.datetime "paid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "due_on"
    t.string "pdf_file_name"
    t.string "pdf_content_type"
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.date "period"
    t.date "issued_on"
    t.string "state", default: "open", null: false
    t.string "friendly_id", default: "fix", null: false
    t.bigint "tenant_id"
    t.datetime "finalized_at"
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
    t.integer "charging_retries_count", default: 0, null: false
    t.date "last_charging_retry"
    t.string "creation_type", default: "manual"
    t.index ["buyer_account_id", "state"], name: "index_invoices_on_buyer_account_id_and_state"
    t.index ["buyer_account_id"], name: "index_invoices_on_buyer_account_id"
    t.index ["provider_account_id", "buyer_account_id"], name: "index_invoices_on_provider_account_id_and_buyer_account_id"
    t.index ["provider_account_id"], name: "index_invoices_on_provider_account_id"
  end

  create_table "legal_term_acceptances", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "legal_term_id"
    t.integer "legal_term_version"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
    t.bigint "account_id"
    t.index ["account_id"], name: "index_legal_term_acceptances_on_account_id"
  end

  create_table "legal_term_bindings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "legal_term_id"
    t.integer "legal_term_version"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "scope"
    t.bigint "tenant_id"
  end

  create_table "legal_term_versions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "legal_term_id"
    t.integer "version"
    t.string "name"
    t.string "slug"
    t.text "body", size: :long
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "published", default: false
    t.boolean "deleted", default: false
    t.boolean "archived", default: false
    t.string "version_comment"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.bigint "tenant_id"
  end

  create_table "legal_terms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "version"
    t.integer "lock_version", default: 0
    t.string "name"
    t.string "slug"
    t.text "body", size: :long
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "published", default: false
    t.boolean "deleted", default: false
    t.boolean "archived", default: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.bigint "account_id"
    t.bigint "tenant_id"
    t.index ["account_id"], name: "index_legal_terms_on_account_id"
  end

  create_table "line_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "invoice_id"
    t.string "name"
    t.string "description"
    t.decimal "cost", precision: 20, scale: 4, default: "0.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type", default: ""
    t.bigint "metric_id"
    t.datetime "finished_at"
    t.integer "quantity"
    t.time "started_at"
    t.bigint "tenant_id"
    t.bigint "contract_id"
    t.string "contract_type"
    t.integer "cinstance_id"
    t.bigint "plan_id"
    t.index ["invoice_id"], name: "index_line_items_on_invoice_id"
  end

  create_table "log_entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "tenant_id"
    t.bigint "provider_id"
    t.bigint "buyer_id"
    t.integer "level", default: 10
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["provider_id"], name: "index_log_entries_on_provider_id"
  end

  create_table "mail_dispatch_rules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "system_operation_id"
    t.text "emails"
    t.boolean "dispatch", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
    t.index ["account_id", "system_operation_id"], name: "index_mail_dispatch_rules_on_account_id_and_system_operation_id", unique: true
  end

  create_table "member_permissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.string "admin_section"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
    t.binary "service_ids"
    t.index ["user_id"], name: "index_member_permissions_on_user_id"
  end

  create_table "message_recipients", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.bigint "receiver_id", null: false
    t.string "receiver_type", default: "", null: false
    t.string "kind", default: "", null: false
    t.integer "position"
    t.string "state", null: false
    t.datetime "hidden_at"
    t.bigint "tenant_id"
    t.datetime "deleted_at"
    t.index ["message_id", "kind"], name: "index_message_recipients_on_message_id_and_kind"
    t.index ["receiver_id"], name: "idx_receiver_id"
  end

  create_table "messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.text "subject"
    t.text "body"
    t.string "state", null: false
    t.datetime "hidden_at"
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "system_operation_id"
    t.text "headers"
    t.bigint "tenant_id"
    t.string "origin"
    t.index ["sender_id", "hidden_at"], name: "index_messages_on_sender_id_and_hidden_at"
  end

  create_table "metrics", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "system_name"
    t.text "description"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at"
    t.bigint "service_id"
    t.string "friendly_name"
    t.bigint "parent_id"
    t.bigint "tenant_id"
    t.bigint "owner_id"
    t.string "owner_type"
    t.index ["owner_type", "owner_id", "system_name"], name: "index_metrics_on_owner_type_and_owner_id_and_system_name", unique: true
    t.index ["owner_type", "owner_id"], name: "index_metrics_on_owner_type_and_owner_id"
    t.index ["parent_id"], name: "index_metrics_on_parent_id"
    t.index ["service_id", "system_name"], name: "index_metrics_on_service_id_and_system_name", unique: true
    t.index ["service_id"], name: "index_metrics_on_service_id"
  end

  create_table "moderatorships", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "forum_id"
    t.bigint "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
  end

  create_table "notification_preferences", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.binary "preferences"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
    t.index ["user_id"], name: "index_notification_preferences_on_user_id", unique: true
  end

  create_table "notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.string "event_id", null: false
    t.string "system_name", limit: 1000
    t.string "state", limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title", limit: 1000
    t.index ["event_id"], name: "index_notifications_on_event_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "oidc_configurations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.text "config"
    t.string "oidc_configurable_type", null: false
    t.bigint "oidc_configurable_id", null: false
    t.bigint "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["oidc_configurable_type", "oidc_configurable_id"], name: "oidc_configurable", unique: true
  end

  create_table "onboardings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "account_id"
    t.string "wizard_state"
    t.string "bubble_api_state"
    t.string "bubble_metric_state"
    t.string "bubble_deployment_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bubble_mapping_state"
    t.string "bubble_limit_state"
    t.bigint "tenant_id"
    t.index ["account_id"], name: "index_onboardings_on_account_id"
  end

  create_table "partners", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name"
    t.string "api_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "system_name"
    t.string "logout_url"
  end

  create_table "payment_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "account_id"
    t.string "buyer_reference"
    t.string "payment_service_reference"
    t.string "credit_card_partial_number"
    t.date "credit_card_expires_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
    t.string "payment_method_id"
    t.index ["account_id", "buyer_reference"], name: "index_payment_details_on_account_id_and_buyer_reference"
    t.index ["account_id", "payment_service_reference"], name: "index_payment_details_on_account_id_and_payment_ref"
    t.index ["account_id"], name: "index_payment_details_on_account_id"
  end

  create_table "payment_gateway_settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.binary "gateway_settings"
    t.string "gateway_type"
    t.bigint "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
    t.index ["account_id"], name: "index_payment_gateway_settings_on_account_id"
  end

  create_table "payment_intents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.string "state"
    t.bigint "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reference"
    t.index ["invoice_id"], name: "index_payment_intents_on_invoice_id"
    t.index ["reference"], name: "index_payment_intents_on_reference", unique: true
    t.index ["state"], name: "index_payment_intents_on_state"
  end

  create_table "payment_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "invoice_id"
    t.boolean "success", default: false, null: false
    t.decimal "amount", precision: 20, scale: 4
    t.string "currency", limit: 4, default: "EUR", null: false
    t.string "reference"
    t.string "message"
    t.string "action"
    t.text "params"
    t.boolean "test", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
    t.index ["invoice_id"], name: "index_payment_transactions_on_invoice_id"
  end

  create_table "plan_metrics", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "plan_id"
    t.bigint "metric_id"
    t.boolean "visible", default: true
    t.boolean "limits_only_text", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "plan_type", null: false
    t.bigint "tenant_id"
    t.index ["metric_id"], name: "idx_plan_metrics_metric_id"
    t.index ["plan_id"], name: "idx_plan_metrics_plan_id"
  end

  create_table "plans", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "issuer_id", null: false
    t.string "name"
    t.string "rights"
    t.text "full_legal", size: :long
    t.decimal "cost_per_month", precision: 20, scale: 4, default: "0.0", null: false
    t.integer "trial_period_days"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position", default: 0
    t.string "state", null: false
    t.integer "cancellation_period", default: 0, null: false
    t.string "cost_aggregation_rule", default: "sum", null: false
    t.decimal "setup_fee", precision: 20, scale: 4, default: "0.0", null: false
    t.boolean "master", default: false
    t.bigint "original_id", default: 0, null: false
    t.string "type", null: false
    t.string "issuer_type", null: false
    t.text "description"
    t.boolean "approval_required", default: false, null: false
    t.bigint "tenant_id"
    t.string "system_name", null: false
    t.bigint "partner_id"
    t.integer "contracts_count", default: 0, null: false
    t.index ["cost_per_month", "setup_fee"], name: "index_plans_on_cost_per_month_and_setup_fee"
    t.index ["issuer_id", "issuer_type", "type", "original_id"], name: "idx_plans_issuer_type_original"
    t.index ["issuer_id"], name: "fk_contracts_service_id"
  end

  create_table "policies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name", null: false
    t.string "version", null: false
    t.binary "schema", size: :long, null: false
    t.bigint "account_id", null: false
    t.bigint "tenant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "identifier"
    t.index ["account_id", "identifier"], name: "index_policies_on_account_id_and_identifier", unique: true
    t.index ["account_id"], name: "index_policies_on_account_id"
  end

  create_table "posts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "topic_id"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "forum_id"
    t.text "body_html"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.boolean "anonymous_user", default: false
    t.bigint "tenant_id"
    t.index ["created_at", "forum_id"], name: "index_posts_on_forum_id"
    t.index ["created_at", "topic_id"], name: "index_posts_on_topic_id"
    t.index ["created_at", "user_id"], name: "index_posts_on_user_id"
  end

  create_table "pricing_rules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "metric_id"
    t.bigint "min", default: 1, null: false
    t.bigint "max"
    t.decimal "cost_per_unit", precision: 20, scale: 4, default: "0.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "plan_id"
    t.bigint "tenant_id"
    t.index ["plan_id"], name: "index_pricing_rules_on_plan_id_and_plan_type"
  end

  create_table "profiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "oneline_description"
    t.text "description"
    t.string "company_url"
    t.string "blog_url"
    t.string "rssfeed_url"
    t.string "email_sales"
    t.string "email_techsupport"
    t.string "email_press"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.string "state"
    t.string "company_type"
    t.string "customers_type"
    t.string "company_size"
    t.string "products_delivered"
    t.bigint "tenant_id"
    t.index ["account_id"], name: "fk_account_id"
  end

  create_table "provided_access_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.text "value"
    t.bigint "user_id"
    t.bigint "tenant_id"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "fk_rails_260e99b630"
  end

  create_table "provider_constraints", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "tenant_id"
    t.bigint "provider_id"
    t.integer "max_users"
    t.integer "max_services"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_constraints_on_provider_id", unique: true
  end

  create_table "proxies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "tenant_id"
    t.bigint "service_id"
    t.string "endpoint"
    t.datetime "deployed_at"
    t.string "auth_app_key", default: "app_key"
    t.string "auth_app_id", default: "app_id"
    t.string "auth_user_key", default: "user_key"
    t.string "credentials_location", default: "query", null: false
    t.string "error_auth_failed", default: "Authentication failed"
    t.string "error_auth_missing", default: "Authentication parameters missing"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "error_status_auth_failed", default: 403, null: false
    t.string "error_headers_auth_failed", default: "text/plain; charset=us-ascii", null: false
    t.integer "error_status_auth_missing", default: 403, null: false
    t.string "error_headers_auth_missing", default: "text/plain; charset=us-ascii", null: false
    t.string "error_no_match", default: "No Mapping Rule matched", null: false
    t.integer "error_status_no_match", default: 404, null: false
    t.string "error_headers_no_match", default: "text/plain; charset=us-ascii", null: false
    t.string "secret_token", null: false
    t.string "hostname_rewrite"
    t.string "oauth_login_url"
    t.string "sandbox_endpoint"
    t.string "api_test_path", limit: 8192
    t.boolean "api_test_success"
    t.boolean "apicast_configuration_driven", default: true, null: false
    t.string "oidc_issuer_endpoint"
    t.bigint "lock_version", default: 0, null: false
    t.string "authentication_method"
    t.text "policies_config", size: :medium
    t.string "oidc_issuer_type", default: "keycloak"
    t.string "error_headers_limits_exceeded", default: "text/plain; charset=us-ascii"
    t.integer "error_status_limits_exceeded", default: 429
    t.string "error_limits_exceeded", default: "Usage limit exceeded"
    t.string "staging_domain"
    t.string "production_domain"
    t.index ["service_id"], name: "index_proxies_on_service_id"
    t.index ["staging_domain", "production_domain"], name: "index_proxies_on_staging_domain_and_production_domain"
  end

  create_table "proxy_config_affecting_changes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.integer "proxy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proxy_id"], name: "index_proxy_config_affecting_changes_on_proxy_id", unique: true
  end

  create_table "proxy_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "proxy_id", null: false
    t.bigint "user_id"
    t.integer "version", default: 0, null: false
    t.bigint "tenant_id"
    t.string "environment", null: false
    t.text "content", size: :medium, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hosts", limit: 8192
    t.index ["proxy_id", "environment", "version"], name: "index_proxy_configs_on_proxy_id_and_environment_and_version"
    t.index ["proxy_id"], name: "index_proxy_configs_on_proxy_id"
    t.index ["user_id"], name: "index_proxy_configs_on_user_id"
  end

  create_table "proxy_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "provider_id"
    t.bigint "tenant_id"
    t.text "lua_file", size: :medium
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "proxy_rules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "proxy_id"
    t.string "http_method"
    t.string "pattern"
    t.bigint "metric_id"
    t.string "metric_system_name"
    t.integer "delta"
    t.bigint "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at"
    t.text "redirect_url"
    t.integer "position"
    t.boolean "last", default: false
    t.bigint "owner_id"
    t.string "owner_type"
    t.index ["owner_type", "owner_id"], name: "index_proxy_rules_on_owner_type_and_owner_id"
    t.index ["proxy_id"], name: "index_proxy_rules_on_proxy_id"
  end

  create_table "referrer_filters", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.string "value", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
    t.index ["application_id"], name: "index_referrer_filters_on_application_id"
  end

  create_table "service_cubert_infos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "bucket_id"
    t.bigint "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tenant_id"
  end

  create_table "service_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "service_id"
    t.string "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
    t.index ["service_id"], name: "index_service_tokens_on_service_id"
  end

  create_table "services", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name", default: ""
    t.text "description"
    t.text "txt_support"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.string "state", null: false
    t.boolean "intentions_required", default: false
    t.text "terms"
    t.boolean "buyers_manage_apps", default: true
    t.boolean "buyers_manage_keys", default: true
    t.boolean "custom_keys_enabled", default: true
    t.string "buyer_plan_change_permission", default: "request"
    t.boolean "buyer_can_select_plan", default: false
    t.text "notification_settings"
    t.bigint "default_application_plan_id"
    t.bigint "default_service_plan_id"
    t.bigint "tenant_id"
    t.string "system_name", null: false
    t.string "backend_version", default: "1", null: false
    t.boolean "mandatory_app_key", default: true
    t.boolean "buyer_key_regenerate_enabled", default: true
    t.string "support_email"
    t.boolean "referrer_filters_required", default: false
    t.string "deployment_option", default: "hosted"
    t.string "kubernetes_service_link"
    t.index ["account_id", "state"], name: "index_services_on_account_id_and_state"
    t.index ["account_id"], name: "idx_account_id"
    t.index ["system_name", "account_id"], name: "index_services_on_system_name_and_account_id_and_deleted_at", unique: true
  end

  create_table "settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "account_id"
    t.string "bg_colour"
    t.string "link_colour"
    t.string "text_colour"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "menu_bg_colour"
    t.string "link_label"
    t.string "link_url"
    t.text "welcome_text"
    t.string "menu_link_colour"
    t.string "content_bg_colour"
    t.string "tracker_code"
    t.string "favicon"
    t.string "plans_tab_bg_colour"
    t.string "plans_bg_colour"
    t.string "content_border_colour"
    t.boolean "forum_enabled", default: true
    t.boolean "app_gallery_enabled", default: false
    t.boolean "anonymous_posts_enabled", default: false
    t.boolean "signups_enabled", default: true
    t.boolean "documentation_enabled", default: true
    t.boolean "useraccountarea_enabled", default: true
    t.text "refund_policy"
    t.text "privacy_policy"
    t.boolean "monthly_charging_enabled", default: true
    t.string "token_api", default: "default"
    t.boolean "documentation_public", default: true, null: false
    t.boolean "forum_public", default: true, null: false
    t.boolean "hide_service"
    t.string "cc_terms_path", default: "/termsofservice"
    t.string "cc_privacy_path", default: "/privacypolicy"
    t.string "cc_refunds_path", default: "/refundpolicy"
    t.string "change_account_plan_permission", default: "request", null: false
    t.boolean "strong_passwords_enabled", default: false
    t.string "change_service_plan_permission", default: "request", null: false
    t.boolean "can_create_service", default: false, null: false
    t.string "spam_protection_level", default: "none", null: false
    t.bigint "tenant_id"
    t.string "multiple_applications_switch", null: false
    t.string "multiple_users_switch", null: false
    t.string "finance_switch", null: false
    t.string "multiple_services_switch", null: false
    t.string "groups_switch", null: false
    t.string "account_plans_switch", null: false
    t.string "authentication_strategy", default: "oauth2", null: false
    t.string "janrain_api_key"
    t.string "janrain_relying_party"
    t.string "service_plans_switch", null: false
    t.boolean "public_search", default: false, null: false
    t.string "product", default: "connect", null: false
    t.string "branding_switch", null: false
    t.boolean "monthly_billing_enabled", default: true, null: false
    t.string "cms_token"
    t.string "cas_server_url"
    t.string "sso_key", limit: 256
    t.string "sso_login_url"
    t.boolean "cms_escape_draft_html", default: true, null: false
    t.boolean "cms_escape_published_html", default: true, null: false
    t.string "heroku_id"
    t.string "heroku_name"
    t.boolean "setup_fee_enabled", default: false
    t.boolean "account_plans_ui_visible", default: false
    t.boolean "service_plans_ui_visible", default: false
    t.string "skip_email_engagement_footer_switch", default: "denied", null: false
    t.string "web_hooks_switch", default: "denied", null: false
    t.string "iam_tools_switch", default: "denied", null: false
    t.string "require_cc_on_signup_switch", default: "denied", null: false
    t.boolean "enforce_sso", default: false, null: false
    t.index ["account_id"], name: "index_settings_on_account_id", unique: true
  end

  create_table "slugs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name"
    t.string "sluggable_type", limit: 50
    t.bigint "sluggable_id"
    t.datetime "created_at"
    t.integer "sequence", default: 1, null: false
    t.bigint "tenant_id"
    t.index ["name", "sluggable_type", "sequence"], name: "index_slugs_on_n_s_and_s"
    t.index ["sluggable_id"], name: "index_slugs_on_sluggable_id"
  end

  create_table "sso_authorizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "uid"
    t.bigint "authentication_provider_id"
    t.bigint "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
    t.text "id_token"
    t.index ["authentication_provider_id"], name: "index_sso_authorizations_on_authentication_provider_id"
    t.index ["user_id"], name: "index_sso_authorizations_on_user_id"
  end

  create_table "system_operations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "ref"
    t.string "name"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "pos"
    t.integer "tenant_id"
  end

  create_table "taggings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "tag_id"
    t.bigint "taggable_id"
    t.string "taggable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
  end

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "account_id"
    t.bigint "tenant_id"
    t.integer "taggings_count", default: 0
    t.index ["account_id"], name: "index_tags_on_account_id"
    t.index ["name", "tenant_id"], name: "index_tags_on_name", unique: true
  end

  create_table "topic_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "forum_id"
    t.bigint "tenant_id"
    t.index ["forum_id"], name: "index_topic_categories_on_forum_id"
  end

  create_table "topics", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "forum_id"
    t.bigint "user_id"
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "hits", default: 0
    t.boolean "sticky", default: false, null: false
    t.integer "posts_count", default: 0
    t.boolean "locked", default: false
    t.bigint "last_post_id"
    t.datetime "last_updated_at"
    t.bigint "last_user_id"
    t.string "permalink"
    t.bigint "category_id"
    t.boolean "delta", default: true, null: false
    t.bigint "tenant_id"
    t.index ["forum_id", "permalink"], name: "index_topics_on_forum_id_and_permalink"
    t.index ["last_updated_at", "forum_id"], name: "index_topics_on_forum_id_and_last_updated_at"
    t.index ["sticky", "last_updated_at", "forum_id"], name: "index_topics_on_sticky_and_last_updated_at"
  end

  create_table "usage_limits", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "metric_id"
    t.string "period"
    t.bigint "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "plan_id"
    t.string "plan_type", null: false
    t.bigint "tenant_id"
    t.index ["metric_id", "plan_id", "period"], name: "index_usage_limits_on_metric_id_and_plan_id_and_period", unique: true
    t.index ["metric_id"], name: "idx_usage_limits_metric_id"
    t.index ["plan_id"], name: "idx_usage_limits_plan_id"
  end

  create_table "user_sessions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.string "key"
    t.string "ip"
    t.string "user_agent"
    t.datetime "accessed_at"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "secured_until"
    t.bigint "sso_authorization_id"
    t.index ["key"], name: "idx_key"
    t.index ["sso_authorization_id"], name: "index_user_sessions_on_sso_authorization_id"
    t.index ["user_id"], name: "idx_user_id"
  end

  create_table "user_topics", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "tenant_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.string "username", limit: 40
    t.string "email"
    t.string "crypted_password", limit: 40
    t.string "salt", limit: 40
    t.datetime "created_at", null: false
    t.datetime "updated_at"
    t.string "remember_token", limit: 40
    t.datetime "remember_token_expires_at"
    t.string "activation_code", limit: 40
    t.datetime "activated_at"
    t.string "state"
    t.string "role", default: ""
    t.string "lost_password_token"
    t.integer "posts_count", default: 0
    t.bigint "account_id"
    t.string "first_name"
    t.string "last_name"
    t.string "signup_type"
    t.string "job_role"
    t.datetime "last_login_at"
    t.string "last_login_ip"
    t.string "email_verification_code"
    t.string "title"
    t.text "extra_fields"
    t.bigint "tenant_id"
    t.string "cas_identifier"
    t.datetime "lost_password_token_generated_at"
    t.string "authentication_id"
    t.string "open_id"
    t.string "password_digest"
    t.index ["account_id"], name: "idx_users_account_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["open_id"], name: "index_users_on_open_id", unique: true
    t.index ["posts_count"], name: "index_site_users_on_posts_count"
    t.index ["username"], name: "index_users_on_login"
  end

  create_table "web_hooks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin", force: :cascade do |t|
    t.bigint "account_id"
    t.string "url"
    t.boolean "account_created_on", default: false
    t.boolean "account_updated_on", default: false
    t.boolean "account_deleted_on", default: false
    t.boolean "user_created_on", default: false
    t.boolean "user_updated_on", default: false
    t.boolean "user_deleted_on", default: false
    t.boolean "application_created_on", default: false
    t.boolean "application_updated_on", default: false
    t.boolean "application_deleted_on", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "provider_actions", default: false
    t.boolean "account_plan_changed_on", default: false
    t.boolean "application_plan_changed_on", default: false
    t.boolean "application_user_key_updated_on", default: false
    t.boolean "application_key_created_on", default: false
    t.boolean "application_key_deleted_on", default: false
    t.boolean "active", default: false
    t.boolean "application_suspended_on", default: false
    t.bigint "tenant_id"
    t.boolean "push_application_content_type", default: true
    t.boolean "application_key_updated_on", default: false
  end

  add_foreign_key "api_docs_services", "services"
  add_foreign_key "payment_details", "accounts", on_delete: :cascade
  add_foreign_key "policies", "accounts", on_delete: :cascade
  add_foreign_key "provided_access_tokens", "users"
  add_foreign_key "proxy_configs", "proxies", on_delete: :cascade
  add_foreign_key "proxy_configs", "users", on_delete: :nullify
  add_foreign_key "sso_authorizations", "authentication_providers"
  add_foreign_key "sso_authorizations", "users"
  add_foreign_key "user_sessions", "sso_authorizations", on_delete: :cascade
end
