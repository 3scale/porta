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

ActiveRecord::Schema.define(version: 20210917163154) do

  create_table "access_tokens", force: :cascade do |t|
    t.integer  "owner_id",   precision: 38, null: false
    t.text     "scopes"
    t.string   "value",                     null: false
    t.string   "name",                      null: false
    t.string   "permission",                null: false
    t.integer  "tenant_id",  precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "accounts", force: :cascade do |t|
    t.string   "org_name",                                                                           default: "",    null: false
    t.string   "org_legaladdress",                                                                   default: ""
    t.datetime "created_at",                                                precision: 6,                            null: false
    t.datetime "updated_at",                                                precision: 6
    t.boolean  "provider",                                                                           default: false
    t.boolean  "buyer",                                                                              default: false
    t.integer  "country_id",                                                precision: 38
    t.integer  "provider_account_id",                                       precision: 38
    t.string   "domain"
    t.string   "telephone_number"
    t.string   "site_access_code"
    t.string   "credit_card_partial_number",                      limit: 4
    t.date     "credit_card_expires_on"
    t.string   "credit_card_auth_code"
    t.boolean  "master"
    t.string   "billing_address_name"
    t.string   "billing_address_address1"
    t.string   "billing_address_address2"
    t.string   "billing_address_city"
    t.string   "billing_address_state"
    t.string   "billing_address_country"
    t.string   "billing_address_zip"
    t.string   "billing_address_phone"
    t.string   "org_legaladdress_cont"
    t.string   "city"
    t.string   "state_region"
    t.string   "state"
    t.boolean  "paid",                                                                               default: false
    t.datetime "paid_at",                                                   precision: 6
    t.boolean  "signs_legal_terms",                                                                  default: true
    t.string   "timezone"
    t.boolean  "delta",                                                                              default: true,  null: false
    t.string   "from_email"
    t.string   "primary_business"
    t.string   "business_category"
    t.string   "zip"
    t.text     "extra_fields"
    t.string   "vat_code"
    t.string   "fiscal_code"
    t.decimal  "vat_rate",                                                  precision: 20, scale: 2
    t.text     "invoice_footnote"
    t.text     "vat_zero_text"
    t.integer  "default_account_plan_id",                                   precision: 38
    t.integer  "default_service_id",                                        precision: 38
    t.string   "credit_card_authorize_net_payment_profile_token"
    t.integer  "tenant_id",                                                 precision: 38
    t.string   "self_domain"
    t.string   "s3_prefix"
    t.integer  "prepared_assets_version",                                   precision: 38
    t.boolean  "sample_data"
    t.integer  "proxy_configs_file_size",                                   precision: 38
    t.datetime "proxy_configs_updated_at",                                  precision: 6
    t.string   "proxy_configs_content_type"
    t.string   "proxy_configs_file_name"
    t.string   "support_email"
    t.string   "finance_support_email"
    t.string   "billing_address_first_name"
    t.string   "billing_address_last_name"
    t.boolean  "email_all_users",                                                                    default: false
    t.integer  "partner_id",                                                precision: 38
    t.string   "proxy_configs_conf_file_name"
    t.string   "proxy_configs_conf_content_type"
    t.integer  "proxy_configs_conf_file_size",                              precision: 38
    t.datetime "proxy_configs_conf_updated_at",                             precision: 6
    t.datetime "hosted_proxy_deployed_at",                                  precision: 6
    t.string   "po_number"
    t.datetime "state_changed_at",                                          precision: 6
  end

  add_index "accounts", ["default_service_id"], name: "index_accounts_on_default_service_id"
  add_index "accounts", ["domain", "state_changed_at"], name: "index_accounts_on_domain_and_state_changed_at"
  add_index "accounts", ["domain"], name: "index_accounts_on_domain", unique: true
  add_index "accounts", ["master"], name: "index_accounts_on_master", unique: true
  add_index "accounts", ["provider_account_id", "created_at"], name: "index_accounts_on_provider_account_id_and_created_at"
  add_index "accounts", ["provider_account_id", "state"], name: "index_accounts_on_provider_account_id_and_state"
  add_index "accounts", ["provider_account_id"], name: "index_accounts_on_provider_account_id"
  add_index "accounts", ["self_domain", "state_changed_at"], name: "index_accounts_on_self_domain_and_state_changed_at"
  add_index "accounts", ["self_domain"], name: "index_accounts_on_self_domain", unique: true
  add_index "accounts", ["state", "state_changed_at"], name: "index_accounts_on_state_and_state_changed_at"

  create_table "alerts", force: :cascade do |t|
    t.integer  "account_id",   precision: 38,           null: false
    t.datetime "timestamp",    precision: 6,            null: false
    t.string   "state",                                 null: false
    t.integer  "cinstance_id", precision: 38,           null: false
    t.decimal  "utilization",  precision: 6,  scale: 2, null: false
    t.integer  "level",        precision: 38,           null: false
    t.integer  "alert_id",     precision: 38,           null: false
    t.text     "message"
    t.integer  "tenant_id",    precision: 38
    t.integer  "service_id",   precision: 38
  end

  add_index "alerts", ["account_id", "service_id", "state", "cinstance_id"], name: "index_alerts_with_service_id"
  add_index "alerts", ["cinstance_id"], name: "index_alerts_on_cinstance_id"
  add_index "alerts", ["timestamp"], name: "index_alerts_on_timestamp"

  create_table "api_docs_services", force: :cascade do |t|
    t.integer  "account_id",               precision: 38
    t.integer  "tenant_id",                precision: 38
    t.string   "name"
    t.text     "body"
    t.text     "description"
    t.boolean  "published",                               default: false
    t.datetime "created_at",               precision: 6
    t.datetime "updated_at",               precision: 6
    t.string   "system_name"
    t.string   "base_path"
    t.string   "swagger_version"
    t.boolean  "skip_swagger_validations",                default: false
    t.integer  "service_id",               precision: 38
    t.boolean  "discovered"
  end

  add_index "api_docs_services", ["service_id"], name: "index_api_docs_services_on_service_id"

  create_table "application_keys", force: :cascade do |t|
    t.integer  "application_id", precision: 38, null: false
    t.string   "value",                         null: false
    t.datetime "created_at",     precision: 6
    t.datetime "updated_at",     precision: 6
    t.integer  "tenant_id",      precision: 38
  end

  add_index "application_keys", ["application_id", "value"], name: "index_application_keys_on_application_id_and_value", unique: true

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id",    precision: 38
    t.string   "auditable_type"
    t.integer  "user_id",         precision: 38
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.integer  "version",         precision: 38, default: 0
    t.datetime "created_at",      precision: 6
    t.integer  "tenant_id",       precision: 38
    t.integer  "provider_id",     precision: 38
    t.string   "kind"
    t.text     "audited_changes"
    t.text     "comment"
    t.integer  "associated_id",   precision: 38
    t.string   "associated_type"
    t.string   "remote_address"
    t.string   "request_uuid"
  end

  add_index "audits", ["action"], name: "index_audits_on_action"
  add_index "audits", ["associated_type", "associated_id"], name: "associated_index"
  add_index "audits", ["auditable_id", "auditable_type", "version"], name: "index_audits_on_auditable_id_and_auditable_type_and_version"
  add_index "audits", ["auditable_type", "auditable_id", "version"], name: "auditable_index"
  add_index "audits", ["created_at"], name: "index_audits_on_created_at"
  add_index "audits", ["kind"], name: "index_audits_on_kind"
  add_index "audits", ["provider_id"], name: "index_audits_on_provider_id"
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid"
  add_index "audits", ["user_id", "user_type"], name: "user_index"
  add_index "audits", ["version"], name: "index_audits_on_version"

  create_table "authentication_providers", force: :cascade do |t|
    t.string   "name"
    t.string   "system_name"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "token_url"
    t.string   "user_info_url"
    t.string   "authorize_url"
    t.string   "site"
    t.integer  "account_id",                        precision: 38
    t.datetime "created_at",                        precision: 6
    t.datetime "updated_at",                        precision: 6
    t.integer  "tenant_id",                         precision: 38
    t.string   "identifier_key",                                   default: "id"
    t.string   "username_key",                                     default: "login"
    t.boolean  "trust_email",                                      default: false
    t.string   "kind"
    t.boolean  "published",                                        default: false
    t.string   "branding_state"
    t.string   "type"
    t.boolean  "skip_ssl_certificate_verification",                default: false
    t.string   "account_type",                                     default: "developer", null: false
    t.boolean  "automatically_approve_accounts",                   default: false
  end

  add_index "authentication_providers", ["account_id", "system_name"], name: "index_authentication_providers_on_account_id_and_system_name", unique: true
  add_index "authentication_providers", ["account_id"], name: "index_authentication_providers_on_account_id"

  create_table "backend_api_configs", force: :cascade do |t|
    t.string   "path",                          default: ""
    t.integer  "service_id",     precision: 38
    t.integer  "backend_api_id", precision: 38
    t.datetime "created_at",     precision: 6,               null: false
    t.datetime "updated_at",     precision: 6,               null: false
    t.integer  "tenant_id",      precision: 38
  end

  add_index "backend_api_configs", ["backend_api_id", "service_id"], name: "index_backend_api_configs_on_backend_api_id_and_service_id", unique: true
  add_index "backend_api_configs", ["path", "service_id"], name: "index_backend_api_configs_on_path_and_service_id", unique: true
  add_index "backend_api_configs", ["service_id"], name: "index_backend_api_configs_on_service_id"

  create_table "backend_apis", force: :cascade do |t|
    t.string   "name",             limit: 511,                                      null: false
    t.string   "system_name",                                                       null: false
    t.text     "description"
    t.string   "private_endpoint"
    t.integer  "account_id",                   precision: 38
    t.datetime "created_at",                   precision: 6,                        null: false
    t.datetime "updated_at",                   precision: 6,                        null: false
    t.integer  "tenant_id",                    precision: 38
    t.string   "state",                                       default: "published", null: false
  end

  add_index "backend_apis", ["account_id", "system_name"], name: "index_backend_apis_on_account_id_and_system_name", unique: true
  add_index "backend_apis", ["state"], name: "index_backend_apis_on_state"

  create_table "backend_events", id: false, force: :cascade do |t|
    t.integer  "id",         precision: 38, null: false
    t.text     "data"
    t.datetime "created_at", precision: 6,  null: false
    t.datetime "updated_at", precision: 6,  null: false
  end

  add_index "backend_events", ["id"], name: "index_backend_events_on_id", unique: true

  create_table "billing_locks", primary_key: "account_id", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
  end

  create_table "billing_strategies", force: :cascade do |t|
    t.integer  "account_id",           precision: 38
    t.boolean  "prepaid",                             default: false
    t.boolean  "charging_enabled",                    default: false
    t.integer  "charging_retry_delay", precision: 38, default: 3
    t.integer  "charging_retry_times", precision: 38, default: 3
    t.datetime "created_at",           precision: 6
    t.datetime "updated_at",           precision: 6
    t.string   "numbering_period",                    default: "monthly"
    t.string   "currency",                            default: "USD"
    t.integer  "tenant_id",            precision: 38
    t.string   "type"
  end

  add_index "billing_strategies", ["account_id"], name: "index_billing_strategies_on_account_id"

  create_table "categories", force: :cascade do |t|
    t.integer  "category_type_id", precision: 38
    t.integer  "parent_id",        precision: 38
    t.string   "name"
    t.datetime "created_at",       precision: 6
    t.datetime "updated_at",       precision: 6
    t.integer  "account_id",       precision: 38
    t.integer  "tenant_id",        precision: 38
  end

  add_index "categories", ["account_id"], name: "index_categories_on_account_id"

  create_table "category_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer  "account_id", precision: 38
    t.integer  "tenant_id",  precision: 38
  end

  add_index "category_types", ["account_id"], name: "index_category_types_on_account_id"

  create_table "cinstances", force: :cascade do |t|
    t.integer  "plan_id",                              precision: 38,                                 null: false
    t.integer  "user_account_id",                      precision: 38
    t.string   "user_key",                 limit: 256
    t.string   "provider_public_key"
    t.datetime "created_at",                           precision: 6,                                  null: false
    t.datetime "updated_at",                           precision: 6
    t.string   "state",                                                                               null: false
    t.text     "description"
    t.datetime "paid_until",                           precision: 6
    t.string   "application_id"
    t.string   "name"
    t.datetime "trial_period_expires_at",              precision: 6
    t.decimal  "setup_fee",                            precision: 20, scale: 2, default: "0.0"
    t.string   "type",                                                          default: "Cinstance", null: false
    t.text     "redirect_url"
    t.datetime "variable_cost_paid_until",             precision: 6
    t.text     "extra_fields"
    t.integer  "tenant_id",                            precision: 38
    t.string   "create_origin"
    t.datetime "first_traffic_at",                     precision: 6
    t.datetime "first_daily_traffic_at",               precision: 6
    t.integer  "service_id",                           precision: 38
    t.datetime "accepted_at",                          precision: 6
  end

  add_index "cinstances", ["application_id"], name: "index_cinstances_on_application_id"
  add_index "cinstances", ["plan_id"], name: "fk_ct_contract_id"
  add_index "cinstances", ["type", "plan_id", "service_id", "state"], name: "index_cinstances_on_type_and_plan_id_and_service_id_and_state"
  add_index "cinstances", ["type", "service_id", "created_at"], name: "index_cinstances_on_type_and_service_id_and_created_at"
  add_index "cinstances", ["type", "service_id", "plan_id", "state"], name: "index_cinstances_on_type_and_service_id_and_plan_id_and_state"
  add_index "cinstances", ["type", "service_id", "state", "first_traffic_at"], name: "idx_cinstances_service_state_traffic"
  add_index "cinstances", ["user_account_id"], name: "fk_ct_user_account_id"
  add_index "cinstances", ["user_key"], name: "index_cinstances_on_user_key"

  create_table "cms_files", force: :cascade do |t|
    t.integer  "provider_id",             precision: 38, null: false
    t.integer  "section_id",              precision: 38
    t.integer  "tenant_id",               precision: 38
    t.datetime "attachment_updated_at",   precision: 6
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size",    precision: 38
    t.string   "attachment_file_name"
    t.string   "random_secret"
    t.string   "path"
    t.boolean  "downloadable"
    t.datetime "created_at",              precision: 6
    t.datetime "updated_at",              precision: 6
  end

  add_index "cms_files", ["provider_id", "path"], name: "index_cms_files_on_provider_id_and_path"
  add_index "cms_files", ["provider_id"], name: "index_cms_files_on_provider_id"
  add_index "cms_files", ["section_id"], name: "index_cms_files_on_section_id"

  create_table "cms_group_sections", force: :cascade do |t|
    t.integer "group_id",   precision: 38
    t.integer "section_id", precision: 38
    t.integer "tenant_id",  precision: 38
  end

  add_index "cms_group_sections", ["group_id"], name: "index_cms_group_sections_on_group_id"

  create_table "cms_groups", force: :cascade do |t|
    t.integer  "tenant_id",   precision: 38
    t.integer  "provider_id", precision: 38, null: false
    t.string   "name"
    t.datetime "created_at",  precision: 6
    t.datetime "updated_at",  precision: 6
  end

  add_index "cms_groups", ["provider_id"], name: "index_cms_groups_on_provider_id"

  create_table "cms_permissions", force: :cascade do |t|
    t.integer  "tenant_id",  precision: 38
    t.integer  "account_id", precision: 38
    t.string   "name"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer  "group_id",   precision: 38
  end

  add_index "cms_permissions", ["account_id"], name: "index_cms_permissions_on_account_id"

  create_table "cms_redirects", force: :cascade do |t|
    t.integer  "provider_id", precision: 38, null: false
    t.string   "source",                     null: false
    t.string   "target",                     null: false
    t.datetime "created_at",  precision: 6
    t.datetime "updated_at",  precision: 6
    t.integer  "tenant_id",   precision: 38
  end

  add_index "cms_redirects", ["provider_id", "source"], name: "index_cms_redirects_on_provider_id_and_source"
  add_index "cms_redirects", ["provider_id"], name: "index_cms_redirects_on_provider_id"

  create_table "cms_sections", force: :cascade do |t|
    t.integer  "provider_id",  precision: 38,                          null: false
    t.integer  "tenant_id",    precision: 38
    t.integer  "parent_id",    precision: 38
    t.string   "partial_path"
    t.string   "title"
    t.string   "system_name"
    t.datetime "created_at",   precision: 6
    t.datetime "updated_at",   precision: 6
    t.boolean  "public",                      default: true
    t.string   "type",                        default: "CMS::Section"
  end

  add_index "cms_sections", ["parent_id"], name: "index_cms_sections_on_parent_id"
  add_index "cms_sections", ["provider_id"], name: "index_cms_sections_on_provider_id"

  create_table "cms_templates", force: :cascade do |t|
    t.integer  "provider_id",     precision: 38,                 null: false
    t.integer  "tenant_id",       precision: 38
    t.integer  "section_id",      precision: 38
    t.string   "type"
    t.string   "path"
    t.string   "title"
    t.string   "system_name"
    t.text     "published"
    t.text     "draft"
    t.boolean  "liquid_enabled"
    t.string   "content_type"
    t.datetime "created_at",      precision: 6
    t.datetime "updated_at",      precision: 6
    t.integer  "layout_id",       precision: 38
    t.text     "options"
    t.string   "updated_by"
    t.string   "handler"
    t.boolean  "searchable",                     default: false
    t.string   "rails_view_path"
  end

  add_index "cms_templates", ["provider_id", "path"], name: "index_cms_templates_on_provider_id_and_path"
  add_index "cms_templates", ["provider_id", "rails_view_path"], name: "index_cms_templates_on_provider_id_and_rails_view_path"
  add_index "cms_templates", ["provider_id", "system_name"], name: "index_cms_templates_on_provider_id_and_system_name"
  add_index "cms_templates", ["provider_id", "type"], name: "index_cms_templates_on_provider_id_type"
  add_index "cms_templates", ["section_id"], name: "index_cms_templates_on_section_id"
  add_index "cms_templates", ["type"], name: "index_cms_templates_on_type"

  create_table "cms_templates_versions", force: :cascade do |t|
    t.integer  "provider_id",    precision: 38,                 null: false
    t.integer  "tenant_id",      precision: 38
    t.integer  "section_id",     precision: 38
    t.string   "type"
    t.string   "path"
    t.string   "title"
    t.string   "system_name"
    t.text     "published"
    t.text     "draft"
    t.boolean  "liquid_enabled"
    t.string   "content_type"
    t.datetime "created_at",     precision: 6
    t.datetime "updated_at",     precision: 6
    t.integer  "layout_id",      precision: 38
    t.integer  "template_id",    precision: 38
    t.string   "template_type"
    t.text     "options"
    t.string   "updated_by"
    t.string   "handler"
    t.boolean  "searchable",                    default: false
  end

  add_index "cms_templates_versions", ["provider_id", "type"], name: "index_cms_templates_versions_on_provider_id_type"
  add_index "cms_templates_versions", ["template_id", "template_type"], name: "by_template"

  create_table "configuration_values", force: :cascade do |t|
    t.integer  "configurable_id",              precision: 38
    t.string   "configurable_type", limit: 50
    t.string   "name"
    t.string   "value"
    t.datetime "created_at",                   precision: 6
    t.datetime "updated_at",                   precision: 6
    t.integer  "tenant_id",                    precision: 38
  end

  add_index "configuration_values", ["configurable_id", "configurable_type", "name"], name: "index_on_configurable_and_name", unique: true
  add_index "configuration_values", ["configurable_id", "configurable_type"], name: "index_on_configurable"

  create_table "countries", force: :cascade do |t|
    t.string   "code"
    t.string   "name"
    t.string   "currency"
    t.decimal  "tax_rate",   precision: 5,  scale: 2, default: "0.0", null: false
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer  "tenant_id",  precision: 38
    t.boolean  "enabled",                             default: true
  end

  add_index "countries", ["code"], name: "index_countries_on_code"

  create_table "deleted_objects", force: :cascade do |t|
    t.integer  "owner_id",    precision: 38
    t.string   "owner_type"
    t.integer  "object_id",   precision: 38
    t.string   "object_type"
    t.datetime "created_at",  precision: 6,  null: false
    t.text     "metadata"
  end

  add_index "deleted_objects", ["object_type", "object_id"], name: "index_deleted_objects_on_object_type_and_object_id"
  add_index "deleted_objects", ["owner_type", "owner_id"], name: "index_deleted_objects_on_owner_type_and_owner_id"

  create_table "event_store_events", force: :cascade do |t|
    t.string   "stream",                     null: false
    t.string   "event_type",                 null: false
    t.string   "event_id",                   null: false
    t.text     "metadata"
    t.text     "data"
    t.datetime "created_at",  precision: 6,  null: false
    t.integer  "provider_id", precision: 38
    t.integer  "tenant_id",   precision: 38
  end

  add_index "event_store_events", ["created_at"], name: "index_event_store_events_on_created_at"
  add_index "event_store_events", ["event_id"], name: "index_event_store_events_on_event_id", unique: true
  add_index "event_store_events", ["provider_id"], name: "index_event_store_events_on_provider_id"
  add_index "event_store_events", ["stream"], name: "index_event_store_events_on_stream"

  create_table "features", force: :cascade do |t|
    t.integer  "featurable_id",   precision: 38
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",      precision: 6
    t.datetime "updated_at",      precision: 6
    t.string   "system_name"
    t.boolean  "visible",                        default: true,              null: false
    t.string   "featurable_type",                default: "Service",         null: false
    t.string   "scope",                          default: "ApplicationPlan", null: false
    t.integer  "tenant_id",       precision: 38
  end

  add_index "features", ["featurable_type", "featurable_id"], name: "index_features_on_featurable_type_and_featurable_id"
  add_index "features", ["featurable_type"], name: "index_features_on_featurable_type"
  add_index "features", ["scope"], name: "index_features_on_scope"
  add_index "features", ["system_name"], name: "index_features_on_system_name"

  create_table "features_plans", id: false, force: :cascade do |t|
    t.integer "plan_id",    precision: 38
    t.integer "feature_id", precision: 38
    t.string  "plan_type",                 null: false
    t.integer "tenant_id",  precision: 38
  end

  add_index "features_plans", ["plan_id", "feature_id"], name: "index_features_plans_on_plan_id_and_feature_id"

  create_table "fields_definitions", force: :cascade do |t|
    t.integer  "account_id", precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string   "target"
    t.boolean  "hidden",                    default: false
    t.boolean  "required",                  default: false
    t.string   "label"
    t.string   "name"
    t.text     "choices"
    t.text     "hint"
    t.boolean  "read_only",                 default: false
    t.integer  "pos",        precision: 38
    t.integer  "tenant_id",  precision: 38
  end

  add_index "fields_definitions", ["account_id"], name: "index_fields_definitions_on_account_id"

  create_table "forums", force: :cascade do |t|
    t.string  "name"
    t.string  "description"
    t.integer "topics_count",     precision: 38, default: 0
    t.integer "posts_count",      precision: 38, default: 0
    t.integer "position",         precision: 38, default: 0
    t.text    "description_html"
    t.string  "state",                           default: "public"
    t.string  "permalink"
    t.integer "account_id",       precision: 38
    t.integer "tenant_id",        precision: 38
  end

  add_index "forums", ["permalink"], name: "index_forums_on_site_id_and_permalink"
  add_index "forums", ["position"], name: "index_forums_on_position_and_site_id"

  create_table "gateway_configurations", force: :cascade do |t|
    t.text     "settings"
    t.integer  "proxy_id",   precision: 38
    t.integer  "tenant_id",  precision: 38
    t.datetime "created_at", precision: 6,  null: false
    t.datetime "updated_at", precision: 6,  null: false
  end

  add_index "gateway_configurations", ["proxy_id"], name: "index_gateway_configurations_on_proxy_id", unique: true

  create_table "go_live_states", force: :cascade do |t|
    t.integer  "account_id", precision: 38
    t.datetime "created_at", precision: 6,                  null: false
    t.datetime "updated_at", precision: 6,                  null: false
    t.text     "steps"
    t.string   "recent"
    t.boolean  "finished",                  default: false
    t.integer  "tenant_id",  precision: 38
  end

  add_index "go_live_states", ["account_id"], name: "index_go_live_states_on_account_id"

  create_table "invitations", force: :cascade do |t|
    t.string   "token"
    t.string   "email"
    t.datetime "sent_at",     precision: 6
    t.datetime "created_at",  precision: 6
    t.datetime "updated_at",  precision: 6
    t.integer  "account_id",  precision: 38
    t.datetime "accepted_at", precision: 6
    t.integer  "tenant_id",   precision: 38
    t.integer  "user_id",     precision: 38
  end

  create_table "invoice_counters", force: :cascade do |t|
    t.integer  "provider_account_id", precision: 38,             null: false
    t.string   "invoice_prefix",                                 null: false
    t.integer  "invoice_count",       precision: 38, default: 0
    t.datetime "created_at",          precision: 6
    t.datetime "updated_at",          precision: 6
  end

  add_index "invoice_counters", ["provider_account_id", "invoice_prefix"], name: "index_invoice_counters_provider_prefix", unique: true

  create_table "invoices", force: :cascade do |t|
    t.integer  "provider_account_id",              precision: 38
    t.integer  "buyer_account_id",                 precision: 38
    t.datetime "paid_at",                          precision: 6
    t.datetime "created_at",                       precision: 6
    t.datetime "updated_at",                       precision: 6
    t.date     "due_on"
    t.string   "pdf_file_name"
    t.string   "pdf_content_type"
    t.integer  "pdf_file_size",                    precision: 38
    t.datetime "pdf_updated_at",                   precision: 6
    t.date     "period"
    t.date     "issued_on"
    t.string   "state",                                                     default: "open",   null: false
    t.string   "friendly_id",                                               default: "fix",    null: false
    t.integer  "tenant_id",                        precision: 38
    t.datetime "finalized_at",                     precision: 6
    t.string   "fiscal_code"
    t.string   "vat_code"
    t.decimal  "vat_rate",                         precision: 20, scale: 2
    t.string   "currency",               limit: 4
    t.string   "from_address_name"
    t.string   "from_address_line1"
    t.string   "from_address_line2"
    t.string   "from_address_city"
    t.string   "from_address_region"
    t.string   "from_address_state"
    t.string   "from_address_country"
    t.string   "from_address_zip"
    t.string   "from_address_phone"
    t.string   "to_address_name"
    t.string   "to_address_line1"
    t.string   "to_address_line2"
    t.string   "to_address_city"
    t.string   "to_address_region"
    t.string   "to_address_state"
    t.string   "to_address_country"
    t.string   "to_address_zip"
    t.string   "to_address_phone"
    t.integer  "charging_retries_count",           precision: 38,           default: 0,        null: false
    t.date     "last_charging_retry"
    t.string   "creation_type",                                             default: "manual"
  end

  add_index "invoices", ["buyer_account_id", "state"], name: "index_invoices_on_buyer_account_id_and_state"
  add_index "invoices", ["buyer_account_id"], name: "index_invoices_on_buyer_account_id"
  add_index "invoices", ["provider_account_id", "buyer_account_id"], name: "index_invoices_on_provider_account_id_and_buyer_account_id"
  add_index "invoices", ["provider_account_id"], name: "index_invoices_on_provider_account_id"

  create_table "legal_term_acceptances", force: :cascade do |t|
    t.integer  "legal_term_id",      precision: 38
    t.integer  "legal_term_version", precision: 38
    t.string   "resource_type"
    t.integer  "resource_id",        precision: 38
    t.datetime "created_at",         precision: 6
    t.datetime "updated_at",         precision: 6
    t.integer  "tenant_id",          precision: 38
    t.integer  "account_id",         precision: 38
  end

  add_index "legal_term_acceptances", ["account_id"], name: "index_legal_term_acceptances_on_account_id"

  create_table "legal_term_bindings", force: :cascade do |t|
    t.integer  "legal_term_id",      precision: 38
    t.integer  "legal_term_version", precision: 38
    t.string   "resource_type"
    t.integer  "resource_id",        precision: 38
    t.datetime "created_at",         precision: 6
    t.datetime "updated_at",         precision: 6
    t.string   "scope"
    t.integer  "tenant_id",          precision: 38
  end

  create_table "legal_term_versions", force: :cascade do |t|
    t.integer  "legal_term_id",   precision: 38
    t.integer  "version",         precision: 38
    t.string   "name"
    t.string   "slug"
    t.text     "body"
    t.datetime "created_at",      precision: 6
    t.datetime "updated_at",      precision: 6
    t.boolean  "published",                      default: false
    t.boolean  "deleted",                        default: false
    t.boolean  "archived",                       default: false
    t.string   "version_comment"
    t.integer  "created_by_id",   precision: 38
    t.integer  "updated_by_id",   precision: 38
    t.integer  "tenant_id",       precision: 38
  end

  create_table "legal_terms", force: :cascade do |t|
    t.integer  "version",       precision: 38
    t.integer  "lock_version",  precision: 38, default: 0
    t.string   "name"
    t.string   "slug"
    t.text     "body"
    t.datetime "created_at",    precision: 6
    t.datetime "updated_at",    precision: 6
    t.boolean  "published",                    default: false
    t.boolean  "deleted",                      default: false
    t.boolean  "archived",                     default: false
    t.integer  "created_by_id", precision: 38
    t.integer  "updated_by_id", precision: 38
    t.integer  "account_id",    precision: 38
    t.integer  "tenant_id",     precision: 38
  end

  add_index "legal_terms", ["account_id"], name: "index_legal_terms_on_account_id"

  create_table "line_items", force: :cascade do |t|
    t.integer  "invoice_id",    precision: 38
    t.string   "name"
    t.string   "description"
    t.decimal  "cost",          precision: 20, scale: 4, default: "0.0", null: false
    t.datetime "created_at",    precision: 6
    t.datetime "updated_at",    precision: 6
    t.string   "type",                                   default: ""
    t.integer  "metric_id",     precision: 38
    t.datetime "finished_at",   precision: 6
    t.integer  "quantity",      precision: 38
    t.date     "started_at"
    t.integer  "tenant_id",     precision: 38
    t.integer  "contract_id",   precision: 38
    t.string   "contract_type"
    t.integer  "cinstance_id",  precision: 38
    t.integer  "plan_id",       precision: 38
  end

  add_index "line_items", ["invoice_id"], name: "index_line_items_on_invoice_id"

  create_table "log_entries", force: :cascade do |t|
    t.integer  "tenant_id",   precision: 38
    t.integer  "provider_id", precision: 38
    t.integer  "buyer_id",    precision: 38
    t.integer  "level",       precision: 38, default: 10
    t.string   "description"
    t.datetime "created_at",  precision: 6
    t.datetime "updated_at",  precision: 6
  end

  add_index "log_entries", ["provider_id"], name: "index_log_entries_on_provider_id"

  create_table "mail_dispatch_rules", force: :cascade do |t|
    t.integer  "account_id",          precision: 38
    t.integer  "system_operation_id", precision: 38
    t.text     "emails"
    t.boolean  "dispatch",                           default: true
    t.datetime "created_at",          precision: 6
    t.datetime "updated_at",          precision: 6
    t.integer  "tenant_id",           precision: 38
  end

  add_index "mail_dispatch_rules", ["system_operation_id", "account_id"], name: "index_mail_dispatch_rules_on_system_operation_id_and_account_id", unique: true

  create_table "member_permissions", force: :cascade do |t|
    t.integer  "user_id",       precision: 38
    t.string   "admin_section"
    t.datetime "created_at",    precision: 6
    t.datetime "updated_at",    precision: 6
    t.integer  "tenant_id",     precision: 38
    t.binary   "service_ids"
  end

  create_table "message_recipients", force: :cascade do |t|
    t.integer  "message_id",    precision: 38,              null: false
    t.integer  "receiver_id",   precision: 38,              null: false
    t.string   "receiver_type",                default: "", null: false
    t.string   "kind",                         default: "", null: false
    t.integer  "position",      precision: 38
    t.string   "state",                                     null: false
    t.datetime "hidden_at",     precision: 6
    t.integer  "tenant_id",     precision: 38
    t.datetime "deleted_at",    precision: 6
  end

  add_index "message_recipients", ["message_id", "kind"], name: "index_message_recipients_on_message_id_and_kind"
  add_index "message_recipients", ["receiver_id"], name: "idx_receiver_id"

  create_table "messages", force: :cascade do |t|
    t.integer  "sender_id",           precision: 38, null: false
    t.text     "subject"
    t.text     "body"
    t.string   "state",                              null: false
    t.datetime "hidden_at",           precision: 6
    t.string   "type"
    t.datetime "created_at",          precision: 6
    t.datetime "updated_at",          precision: 6
    t.integer  "system_operation_id", precision: 38
    t.text     "headers"
    t.integer  "tenant_id",           precision: 38
    t.string   "origin"
  end

  add_index "messages", ["sender_id", "hidden_at"], name: "index_messages_on_sender_id_and_hidden_at"

  create_table "metrics", force: :cascade do |t|
    t.string   "system_name"
    t.text     "description"
    t.string   "unit"
    t.datetime "created_at",    precision: 6,  null: false
    t.datetime "updated_at",    precision: 6
    t.integer  "service_id",    precision: 38
    t.string   "friendly_name"
    t.integer  "parent_id",     precision: 38
    t.integer  "tenant_id",     precision: 38
    t.integer  "owner_id",      precision: 38
    t.string   "owner_type"
  end

  add_index "metrics", ["owner_type", "owner_id", "system_name"], name: "index_metrics_on_owner_type_and_owner_id_and_system_name", unique: true
  add_index "metrics", ["owner_type", "owner_id"], name: "index_metrics_on_owner_type_and_owner_id"
  add_index "metrics", ["parent_id"], name: "index_metrics_on_parent_id"
  add_index "metrics", ["service_id", "system_name"], name: "index_metrics_on_service_id_and_system_name", unique: true
  add_index "metrics", ["service_id"], name: "index_metrics_on_service_id"

  create_table "moderatorships", force: :cascade do |t|
    t.integer  "forum_id",   precision: 38
    t.integer  "user_id",    precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer  "tenant_id",  precision: 38
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.integer  "user_id",     precision: 38
    t.binary   "preferences"
    t.datetime "created_at",  precision: 6
    t.datetime "updated_at",  precision: 6
    t.integer  "tenant_id",   precision: 38
  end

  add_index "notification_preferences", ["user_id"], name: "index_notification_preferences_on_user_id", unique: true

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",                  precision: 38
    t.string   "event_id",                                null: false
    t.string   "system_name", limit: 1000
    t.string   "state",       limit: 20
    t.datetime "created_at",               precision: 6
    t.datetime "updated_at",               precision: 6
    t.string   "title",       limit: 1000
  end

  add_index "notifications", ["event_id"], name: "index_notifications_on_event_id"
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id"

  create_table "oidc_configurations", force: :cascade do |t|
    t.text     "config"
    t.string   "oidc_configurable_type",                null: false
    t.integer  "oidc_configurable_id",   precision: 38, null: false
    t.integer  "tenant_id",              precision: 38
    t.datetime "created_at",             precision: 6,  null: false
    t.datetime "updated_at",             precision: 6,  null: false
  end

  add_index "oidc_configurations", ["oidc_configurable_type", "oidc_configurable_id"], name: "oidc_configurable", unique: true

  create_table "onboardings", force: :cascade do |t|
    t.integer  "account_id",              precision: 38
    t.string   "wizard_state"
    t.string   "bubble_api_state"
    t.string   "bubble_metric_state"
    t.string   "bubble_deployment_state"
    t.datetime "created_at",              precision: 6,  null: false
    t.datetime "updated_at",              precision: 6,  null: false
    t.string   "bubble_mapping_state"
    t.string   "bubble_limit_state"
    t.integer  "tenant_id",               precision: 38
  end

  add_index "onboardings", ["account_id"], name: "index_onboardings_on_account_id"

  create_table "partners", force: :cascade do |t|
    t.string   "name"
    t.string   "api_key"
    t.datetime "created_at",  precision: 6, null: false
    t.datetime "updated_at",  precision: 6, null: false
    t.string   "system_name"
    t.string   "logout_url"
  end

  create_table "payment_details", force: :cascade do |t|
    t.integer  "account_id",                 precision: 38
    t.string   "buyer_reference"
    t.string   "payment_service_reference"
    t.string   "credit_card_partial_number"
    t.date     "credit_card_expires_on"
    t.datetime "created_at",                 precision: 6,  null: false
    t.datetime "updated_at",                 precision: 6,  null: false
    t.integer  "tenant_id",                  precision: 38
    t.string   "payment_method_id"
  end

  add_index "payment_details", ["account_id", "buyer_reference"], name: "index_payment_details_on_account_id_and_buyer_reference"
  add_index "payment_details", ["account_id", "payment_service_reference"], name: "index_payment_details_on_account_id_and_payment_ref"
  add_index "payment_details", ["account_id"], name: "index_payment_details_on_account_id"

  create_table "payment_gateway_settings", force: :cascade do |t|
    t.binary   "gateway_settings"
    t.string   "gateway_type"
    t.integer  "account_id",       precision: 38
    t.datetime "created_at",       precision: 6
    t.datetime "updated_at",       precision: 6
    t.integer  "tenant_id",        precision: 38
  end

  create_table "payment_intents", force: :cascade do |t|
    t.integer  "invoice_id",        precision: 38, null: false
    t.string   "payment_intent_id"
    t.string   "state"
    t.integer  "tenant_id",         precision: 38
    t.datetime "created_at",        precision: 6,  null: false
    t.datetime "updated_at",        precision: 6,  null: false
    t.string   "reference"
  end

  add_index "payment_intents", ["invoice_id"], name: "index_payment_intents_on_invoice_id"
  add_index "payment_intents", ["payment_intent_id"], name: "index_payment_intents_on_payment_intent_id"
  add_index "payment_intents", ["reference"], name: "index_payment_intents_on_reference", unique: true
  add_index "payment_intents", ["state"], name: "index_payment_intents_on_state"

  create_table "payment_transactions", force: :cascade do |t|
    t.integer  "account_id",           precision: 38
    t.integer  "invoice_id",           precision: 38
    t.boolean  "success",                                       default: false, null: false
    t.decimal  "amount",               precision: 20, scale: 4
    t.string   "currency",   limit: 4,                          default: "EUR", null: false
    t.string   "reference"
    t.string   "message"
    t.string   "action"
    t.text     "params"
    t.boolean  "test",                                          default: false, null: false
    t.datetime "created_at",           precision: 6
    t.datetime "updated_at",           precision: 6
    t.integer  "tenant_id",            precision: 38
  end

  add_index "payment_transactions", ["invoice_id"], name: "index_payment_transactions_on_invoice_id"

  create_table "plan_metrics", force: :cascade do |t|
    t.integer  "plan_id",          precision: 38
    t.integer  "metric_id",        precision: 38
    t.boolean  "visible",                         default: true
    t.boolean  "limits_only_text",                default: true
    t.datetime "created_at",       precision: 6
    t.datetime "updated_at",       precision: 6
    t.string   "plan_type",                                      null: false
    t.integer  "tenant_id",        precision: 38
  end

  add_index "plan_metrics", ["metric_id"], name: "idx_plan_metrics_metric_id"
  add_index "plan_metrics", ["plan_id"], name: "idx_plan_metrics_plan_id"

  create_table "plans", force: :cascade do |t|
    t.integer  "issuer_id",             precision: 38,                           null: false
    t.string   "name"
    t.string   "rights"
    t.text     "full_legal"
    t.decimal  "cost_per_month",        precision: 20, scale: 4, default: "0.0", null: false
    t.integer  "trial_period_days",     precision: 38
    t.datetime "created_at",            precision: 6
    t.datetime "updated_at",            precision: 6
    t.integer  "position",              precision: 38,           default: 0
    t.string   "state",                                                          null: false
    t.integer  "cancellation_period",   precision: 38,           default: 0,     null: false
    t.string   "cost_aggregation_rule",                          default: "sum", null: false
    t.decimal  "setup_fee",             precision: 20, scale: 4, default: "0.0", null: false
    t.boolean  "master",                                         default: false
    t.integer  "original_id",           precision: 38,           default: 0,     null: false
    t.string   "type",                                                           null: false
    t.string   "issuer_type",                                                    null: false
    t.text     "description"
    t.boolean  "approval_required",                              default: false, null: false
    t.integer  "tenant_id",             precision: 38
    t.string   "system_name",                                                    null: false
    t.integer  "partner_id",            precision: 38
    t.integer  "contracts_count",       precision: 38,           default: 0,     null: false
  end

  add_index "plans", ["cost_per_month", "setup_fee"], name: "index_plans_on_cost_per_month_and_setup_fee"
  add_index "plans", ["issuer_id", "issuer_type", "type", "original_id"], name: "idx_plans_issuer_type_original"
  add_index "plans", ["issuer_id"], name: "fk_contracts_service_id"

  create_table "policies", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "version",                   null: false
    t.binary   "schema",                    null: false
    t.integer  "account_id", precision: 38, null: false
    t.integer  "tenant_id",  precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string   "identifier"
  end

  add_index "policies", ["account_id", "identifier"], name: "index_policies_on_account_id_and_identifier", unique: true
  add_index "policies", ["account_id"], name: "index_policies_on_account_id"

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id",        precision: 38
    t.integer  "topic_id",       precision: 38
    t.text     "body"
    t.datetime "created_at",     precision: 6
    t.datetime "updated_at",     precision: 6
    t.integer  "forum_id",       precision: 38
    t.text     "body_html"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "anonymous_user",                default: false
    t.integer  "tenant_id",      precision: 38
  end

  add_index "posts", ["created_at", "forum_id"], name: "index_posts_on_forum_id"
  add_index "posts", ["created_at", "topic_id"], name: "index_posts_on_topic_id"
  add_index "posts", ["created_at", "user_id"], name: "index_posts_on_user_id"

  create_table "pricing_rules", force: :cascade do |t|
    t.integer  "metric_id",     precision: 38
    t.integer  "min",           precision: 38,           default: 1,     null: false
    t.integer  "max",           precision: 38
    t.decimal  "cost_per_unit", precision: 20, scale: 4, default: "0.0", null: false
    t.datetime "created_at",    precision: 6
    t.datetime "updated_at",    precision: 6
    t.integer  "plan_id",       precision: 38
    t.integer  "tenant_id",     precision: 38
  end

  create_table "profiles", force: :cascade do |t|
    t.integer  "account_id",          precision: 38,              null: false
    t.string   "oneline_description",                default: ""
    t.text     "description"
    t.string   "company_url"
    t.string   "blog_url"
    t.string   "rssfeed_url"
    t.string   "email_sales"
    t.string   "email_techsupport"
    t.string   "email_press"
    t.datetime "created_at",          precision: 6
    t.datetime "updated_at",          precision: 6
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size",      precision: 38
    t.string   "state"
    t.string   "company_type"
    t.string   "customers_type"
    t.string   "company_size"
    t.string   "products_delivered"
    t.integer  "tenant_id",           precision: 38
  end

  add_index "profiles", ["account_id"], name: "fk_account_id"

  create_table "provided_access_tokens", force: :cascade do |t|
    t.text     "value"
    t.integer  "user_id",    precision: 38
    t.integer  "tenant_id",  precision: 38
    t.datetime "expires_at", precision: 6
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "provider_constraints", force: :cascade do |t|
    t.integer  "tenant_id",    precision: 38
    t.integer  "provider_id",  precision: 38
    t.integer  "max_users",    precision: 38
    t.integer  "max_services", precision: 38
    t.datetime "created_at",   precision: 6,  null: false
    t.datetime "updated_at",   precision: 6,  null: false
  end

  add_index "provider_constraints", ["provider_id"], name: "index_provider_constraints_on_provider_id", unique: true

  create_table "proxies", force: :cascade do |t|
    t.integer  "tenant_id",                                  precision: 38
    t.integer  "service_id",                                 precision: 38
    t.string   "endpoint"
    t.datetime "deployed_at",                                precision: 6
    t.string   "auth_app_key",                                              default: "app_key"
    t.string   "auth_app_id",                                               default: "app_id"
    t.string   "auth_user_key",                                             default: "user_key"
    t.string   "credentials_location",                                      default: "query",                             null: false
    t.string   "error_auth_failed",                                         default: "Authentication failed"
    t.string   "error_auth_missing",                                        default: "Authentication parameters missing"
    t.datetime "created_at",                                 precision: 6
    t.datetime "updated_at",                                 precision: 6
    t.integer  "error_status_auth_failed",                   precision: 38, default: 403,                                 null: false
    t.string   "error_headers_auth_failed",                                 default: "text/plain; charset=us-ascii",      null: false
    t.integer  "error_status_auth_missing",                  precision: 38, default: 403,                                 null: false
    t.string   "error_headers_auth_missing",                                default: "text/plain; charset=us-ascii",      null: false
    t.string   "error_no_match",                                            default: "No Mapping Rule matched",           null: false
    t.integer  "error_status_no_match",                      precision: 38, default: 404,                                 null: false
    t.string   "error_headers_no_match",                                    default: "text/plain; charset=us-ascii",      null: false
    t.string   "secret_token",                                                                                            null: false
    t.string   "hostname_rewrite"
    t.string   "oauth_login_url"
    t.string   "sandbox_endpoint"
    t.string   "api_test_path",                 limit: 8192
    t.boolean  "api_test_success"
    t.boolean  "apicast_configuration_driven",                              default: true,                                null: false
    t.string   "oidc_issuer_endpoint"
    t.string   "authentication_method"
    t.integer  "lock_version",                               precision: 38, default: 0,                                   null: false
    t.text     "policies_config"
    t.string   "oidc_issuer_type",                                          default: "keycloak"
    t.string   "error_headers_limits_exceeded",                             default: "text/plain; charset=us-ascii"
    t.integer  "error_status_limits_exceeded",               precision: 38, default: 429
    t.string   "error_limits_exceeded",                                     default: "Usage limit exceeded"
    t.string   "staging_domain"
    t.string   "production_domain"
  end

  add_index "proxies", ["service_id"], name: "index_proxies_on_service_id"
  add_index "proxies", ["staging_domain", "production_domain"], name: "index_proxies_on_staging_domain_and_production_domain"

  create_table "proxy_config_affecting_changes", force: :cascade do |t|
    t.integer  "proxy_id",   precision: 38, null: false
    t.datetime "created_at", precision: 6,  null: false
    t.datetime "updated_at", precision: 6,  null: false
  end

  add_index "proxy_config_affecting_changes", ["proxy_id"], name: "index_proxy_config_affecting_changes_on_proxy_id", unique: true

  create_table "proxy_configs", force: :cascade do |t|
    t.integer  "proxy_id",                 precision: 38,             null: false
    t.integer  "user_id",                  precision: 38
    t.integer  "version",                  precision: 38, default: 0, null: false
    t.integer  "tenant_id",                precision: 38
    t.string   "environment",                                         null: false
    t.text     "content",                                             null: false
    t.datetime "created_at",               precision: 6,              null: false
    t.datetime "updated_at",               precision: 6,              null: false
    t.string   "hosts",       limit: 8192
  end

  add_index "proxy_configs", ["proxy_id", "environment", "version"], name: "index_proxy_configs_on_proxy_id_and_environment_and_version"
  add_index "proxy_configs", ["proxy_id"], name: "index_proxy_configs_on_proxy_id"
  add_index "proxy_configs", ["user_id"], name: "index_proxy_configs_on_user_id"

  create_table "proxy_logs", force: :cascade do |t|
    t.integer  "provider_id", precision: 38
    t.integer  "tenant_id",   precision: 38
    t.text     "lua_file"
    t.string   "status"
    t.datetime "created_at",  precision: 6
    t.datetime "updated_at",  precision: 6
  end

  create_table "proxy_rules", force: :cascade do |t|
    t.integer  "proxy_id",           precision: 38
    t.string   "http_method"
    t.string   "pattern"
    t.integer  "metric_id",          precision: 38
    t.string   "metric_system_name"
    t.integer  "delta",              precision: 38
    t.integer  "tenant_id",          precision: 38
    t.datetime "created_at",         precision: 6,                  null: false
    t.datetime "updated_at",         precision: 6
    t.text     "redirect_url"
    t.integer  "position",           precision: 38
    t.boolean  "last",                              default: false
    t.integer  "owner_id",           precision: 38
    t.string   "owner_type"
  end

  add_index "proxy_rules", ["owner_type", "owner_id"], name: "index_proxy_rules_on_owner_type_and_owner_id"
  add_index "proxy_rules", ["proxy_id"], name: "index_proxy_rules_on_proxy_id"

  create_table "referrer_filters", force: :cascade do |t|
    t.integer  "application_id", precision: 38, null: false
    t.string   "value",                         null: false
    t.datetime "created_at",     precision: 6
    t.datetime "updated_at",     precision: 6
    t.integer  "tenant_id",      precision: 38
  end

  add_index "referrer_filters", ["application_id"], name: "index_referrer_filters_on_application_id"

  create_table "service_cubert_infos", force: :cascade do |t|
    t.string   "bucket_id"
    t.integer  "service_id", precision: 38
    t.datetime "created_at", precision: 6,  null: false
    t.datetime "updated_at", precision: 6,  null: false
    t.integer  "tenant_id",  precision: 38
  end

  create_table "service_tokens", force: :cascade do |t|
    t.integer  "service_id", precision: 38
    t.string   "value"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer  "tenant_id",  precision: 38
  end

  add_index "service_tokens", ["service_id"], name: "index_service_tokens_on_service_id"

  create_table "services", force: :cascade do |t|
    t.integer  "account_id",                   precision: 38,                     null: false
    t.string   "name",                                        default: ""
    t.text     "description"
    t.text     "txt_support"
    t.datetime "created_at",                   precision: 6
    t.datetime "updated_at",                   precision: 6
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size",               precision: 38
    t.string   "state",                                                           null: false
    t.boolean  "intentions_required",                         default: false
    t.text     "terms"
    t.boolean  "buyers_manage_apps",                          default: true
    t.boolean  "buyers_manage_keys",                          default: true
    t.boolean  "custom_keys_enabled",                         default: true
    t.string   "buyer_plan_change_permission",                default: "request"
    t.boolean  "buyer_can_select_plan",                       default: false
    t.text     "notification_settings"
    t.integer  "default_application_plan_id",  precision: 38
    t.integer  "default_service_plan_id",      precision: 38
    t.integer  "tenant_id",                    precision: 38
    t.string   "system_name",                                                     null: false
    t.string   "backend_version",                             default: "1",       null: false
    t.boolean  "mandatory_app_key",                           default: true
    t.boolean  "buyer_key_regenerate_enabled",                default: true
    t.string   "support_email"
    t.boolean  "referrer_filters_required",                   default: false
    t.string   "deployment_option",                           default: "hosted"
    t.string   "kubernetes_service_link"
  end

  add_index "services", ["account_id", "state"], name: "index_services_on_account_id_and_state"
  add_index "services", ["account_id"], name: "idx_account_id"
  add_index "services", ["system_name", "account_id"], name: "index_services_on_system_name_and_account_id_and_deleted_at", unique: true

  create_table "settings", force: :cascade do |t|
    t.integer  "account_id",                                      precision: 38
    t.string   "bg_colour"
    t.string   "link_colour"
    t.string   "text_colour"
    t.datetime "created_at",                                      precision: 6
    t.datetime "updated_at",                                      precision: 6
    t.string   "menu_bg_colour"
    t.string   "link_label"
    t.string   "link_url"
    t.text     "welcome_text"
    t.string   "menu_link_colour"
    t.string   "content_bg_colour"
    t.string   "tracker_code"
    t.string   "favicon"
    t.string   "plans_tab_bg_colour"
    t.string   "plans_bg_colour"
    t.string   "content_border_colour"
    t.boolean  "forum_enabled",                                                  default: true
    t.boolean  "app_gallery_enabled",                                            default: false
    t.boolean  "anonymous_posts_enabled",                                        default: false
    t.boolean  "signups_enabled",                                                default: true
    t.boolean  "documentation_enabled",                                          default: true
    t.boolean  "useraccountarea_enabled",                                        default: true
    t.text     "refund_policy"
    t.text     "privacy_policy"
    t.boolean  "monthly_charging_enabled",                                       default: true
    t.string   "token_api",                                                      default: "default"
    t.boolean  "documentation_public",                                           default: true,              null: false
    t.boolean  "forum_public",                                                   default: true,              null: false
    t.boolean  "hide_service"
    t.string   "cc_terms_path",                                                  default: "/termsofservice"
    t.string   "cc_privacy_path",                                                default: "/privacypolicy"
    t.string   "cc_refunds_path",                                                default: "/refundpolicy"
    t.string   "change_account_plan_permission",                                 default: "request",         null: false
    t.boolean  "strong_passwords_enabled",                                       default: false
    t.string   "change_service_plan_permission",                                 default: "request",         null: false
    t.boolean  "can_create_service",                                             default: false,             null: false
    t.string   "spam_protection_level",                                          default: "none",            null: false
    t.integer  "tenant_id",                                       precision: 38
    t.string   "multiple_applications_switch",                                                               null: false
    t.string   "multiple_users_switch",                                                                      null: false
    t.string   "finance_switch",                                                                             null: false
    t.string   "multiple_services_switch",                                                                   null: false
    t.string   "groups_switch",                                                                              null: false
    t.string   "account_plans_switch",                                                                       null: false
    t.string   "authentication_strategy",                                        default: "oauth2",          null: false
    t.string   "janrain_api_key"
    t.string   "janrain_relying_party"
    t.string   "service_plans_switch",                                                                       null: false
    t.boolean  "public_search",                                                  default: false,             null: false
    t.string   "product",                                                        default: "connect",         null: false
    t.string   "branding_switch",                                                                            null: false
    t.boolean  "monthly_billing_enabled",                                        default: true,              null: false
    t.string   "cms_token"
    t.string   "cas_server_url"
    t.string   "sso_key",                             limit: 256
    t.string   "sso_login_url"
    t.boolean  "cms_escape_draft_html",                                          default: true,              null: false
    t.boolean  "cms_escape_published_html",                                      default: true,              null: false
    t.string   "heroku_id"
    t.string   "heroku_name"
    t.boolean  "setup_fee_enabled",                                              default: false
    t.boolean  "account_plans_ui_visible",                                       default: false
    t.boolean  "service_plans_ui_visible",                                       default: false
    t.string   "skip_email_engagement_footer_switch",                            default: "denied",          null: false
    t.string   "web_hooks_switch",                                               default: "denied",          null: false
    t.string   "iam_tools_switch",                                               default: "denied",          null: false
    t.string   "require_cc_on_signup_switch",                                    default: "denied",          null: false
    t.boolean  "enforce_sso",                                                    default: false,             null: false
  end

  add_index "settings", ["account_id"], name: "index_settings_on_account_id", unique: true

  create_table "slugs", force: :cascade do |t|
    t.string   "name"
    t.string   "sluggable_type", limit: 50
    t.integer  "sluggable_id",              precision: 38
    t.datetime "created_at",                precision: 6
    t.integer  "sequence",                  precision: 38, default: 1, null: false
    t.integer  "tenant_id",                 precision: 38
  end

  add_index "slugs", ["name", "sluggable_type", "sequence"], name: "index_slugs_on_n_s_and_s"
  add_index "slugs", ["sluggable_id"], name: "index_slugs_on_sluggable_id"

  create_table "sso_authorizations", force: :cascade do |t|
    t.string   "uid"
    t.integer  "authentication_provider_id", precision: 38
    t.integer  "user_id",                    precision: 38
    t.datetime "created_at",                 precision: 6
    t.datetime "updated_at",                 precision: 6
    t.integer  "tenant_id",                  precision: 38
    t.text     "id_token"
  end

  add_index "sso_authorizations", ["authentication_provider_id"], name: "index_sso_authorizations_on_authentication_provider_id"
  add_index "sso_authorizations", ["user_id"], name: "index_sso_authorizations_on_user_id"

  create_table "system_operations", force: :cascade do |t|
    t.string   "ref"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  precision: 6
    t.datetime "updated_at",  precision: 6
    t.integer  "pos",         precision: 38
    t.integer  "tenant_id",   precision: 38
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        precision: 38
    t.integer  "taggable_id",   precision: 38
    t.string   "taggable_type"
    t.datetime "created_at",    precision: 6
    t.datetime "updated_at",    precision: 6
    t.integer  "tenant_id",     precision: 38
    t.integer  "tagger_id",     precision: 38
    t.string   "tagger_type"
    t.string   "context"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",     precision: 6
    t.datetime "updated_at",     precision: 6
    t.integer  "account_id",     precision: 38
    t.integer  "tenant_id",      precision: 38
    t.integer  "taggings_count", precision: 38, default: 0
  end

  add_index "tags", ["account_id"], name: "index_tags_on_account_id"

  create_table "topic_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer  "forum_id",   precision: 38
    t.integer  "tenant_id",  precision: 38
  end

  add_index "topic_categories", ["forum_id"], name: "index_topic_categories_on_forum_id"

  create_table "topics", force: :cascade do |t|
    t.integer  "forum_id",        precision: 38
    t.integer  "user_id",         precision: 38
    t.string   "title"
    t.datetime "created_at",      precision: 6
    t.datetime "updated_at",      precision: 6
    t.integer  "hits",            precision: 38, default: 0
    t.boolean  "sticky",                         default: false, null: false
    t.integer  "posts_count",     precision: 38, default: 0
    t.boolean  "locked",                         default: false
    t.integer  "last_post_id",    precision: 38
    t.datetime "last_updated_at", precision: 6
    t.integer  "last_user_id",    precision: 38
    t.string   "permalink"
    t.integer  "category_id",     precision: 38
    t.boolean  "delta",                          default: true,  null: false
    t.integer  "tenant_id",       precision: 38
  end

  add_index "topics", ["forum_id", "permalink"], name: "index_topics_on_forum_id_and_permalink"
  add_index "topics", ["last_updated_at", "forum_id"], name: "index_topics_on_forum_id_and_last_updated_at"
  add_index "topics", ["sticky", "last_updated_at", "forum_id"], name: "index_topics_on_sticky_and_last_updated_at"

  create_table "usage_limits", force: :cascade do |t|
    t.integer  "metric_id",  precision: 38
    t.string   "period"
    t.integer  "value",      precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer  "plan_id",    precision: 38
    t.string   "plan_type",                 null: false
    t.integer  "tenant_id",  precision: 38
  end

  add_index "usage_limits", ["metric_id", "plan_id", "period"], name: "index_usage_limits_on_metric_id_and_plan_id_and_period", unique: true
  add_index "usage_limits", ["metric_id"], name: "idx_usage_limits_metric_id"
  add_index "usage_limits", ["plan_id"], name: "idx_usage_limits_plan_id"

  create_table "user_sessions", force: :cascade do |t|
    t.integer  "user_id",              precision: 38
    t.string   "key"
    t.string   "ip"
    t.string   "user_agent"
    t.datetime "accessed_at",          precision: 6
    t.datetime "revoked_at",           precision: 6
    t.datetime "created_at",           precision: 6,  null: false
    t.datetime "updated_at",           precision: 6,  null: false
    t.datetime "secured_until",        precision: 6
    t.integer  "sso_authorization_id", precision: 38
  end

  add_index "user_sessions", ["key"], name: "idx_key"
  add_index "user_sessions", ["user_id"], name: "idx_user_id"

  create_table "user_topics", force: :cascade do |t|
    t.integer  "user_id",    precision: 38
    t.integer  "topic_id",   precision: 38
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer  "tenant_id",  precision: 38
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",                         limit: 40
    t.string   "email"
    t.string   "crypted_password",                 limit: 40
    t.string   "salt",                             limit: 40
    t.datetime "created_at",                                  precision: 6,               null: false
    t.datetime "updated_at",                                  precision: 6
    t.string   "remember_token",                   limit: 40
    t.datetime "remember_token_expires_at",                   precision: 6
    t.string   "activation_code",                  limit: 40
    t.datetime "activated_at",                                precision: 6
    t.string   "state"
    t.string   "role",                                                       default: ""
    t.string   "lost_password_token"
    t.integer  "posts_count",                                 precision: 38, default: 0
    t.integer  "account_id",                                  precision: 38
    t.string   "first_name"
    t.string   "last_name"
    t.string   "signup_type"
    t.string   "job_role"
    t.datetime "last_login_at",                               precision: 6
    t.string   "last_login_ip"
    t.string   "email_verification_code"
    t.string   "title"
    t.text     "extra_fields"
    t.integer  "tenant_id",                                   precision: 38
    t.string   "cas_identifier"
    t.datetime "lost_password_token_generated_at",            precision: 6
    t.string   "authentication_id"
    t.string   "open_id"
    t.string   "password_digest"
  end

  add_index "users", ["account_id"], name: "idx_users_account_id"
  add_index "users", ["email"], name: "index_users_on_email"
  add_index "users", ["open_id"], name: "index_users_on_open_id", unique: true
  add_index "users", ["posts_count"], name: "index_site_users_on_posts_count"
  add_index "users", ["username"], name: "index_users_on_login"

  create_table "web_hooks", force: :cascade do |t|
    t.integer  "account_id",                      precision: 38
    t.string   "url"
    t.boolean  "account_created_on",                             default: false
    t.boolean  "account_updated_on",                             default: false
    t.boolean  "account_deleted_on",                             default: false
    t.boolean  "user_created_on",                                default: false
    t.boolean  "user_updated_on",                                default: false
    t.boolean  "user_deleted_on",                                default: false
    t.boolean  "application_created_on",                         default: false
    t.boolean  "application_updated_on",                         default: false
    t.boolean  "application_deleted_on",                         default: false
    t.datetime "created_at",                      precision: 6
    t.datetime "updated_at",                      precision: 6
    t.boolean  "provider_actions",                               default: false
    t.boolean  "account_plan_changed_on",                        default: false
    t.boolean  "application_plan_changed_on",                    default: false
    t.boolean  "application_user_key_updated_on",                default: false
    t.boolean  "application_key_created_on",                     default: false
    t.boolean  "application_key_deleted_on",                     default: false
    t.boolean  "active",                                         default: false
    t.boolean  "application_suspended_on",                       default: false
    t.integer  "tenant_id",                       precision: 38
    t.boolean  "push_application_content_type",                  default: true
    t.boolean  "application_key_updated_on",                     default: false
  end

  add_foreign_key "api_docs_services", "services"
  add_foreign_key "payment_details", "accounts", on_delete: :cascade
  add_foreign_key "policies", "accounts", on_delete: :cascade
  add_foreign_key "provided_access_tokens", "users"
  add_foreign_key "proxy_configs", "proxies", on_delete: :cascade
  add_foreign_key "proxy_configs", "users", on_delete: :nullify
  add_foreign_key "sso_authorizations", "authentication_providers"
  add_foreign_key "sso_authorizations", "users"
end
