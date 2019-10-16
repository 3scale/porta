# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20191007101321) do

  create_table "access_tokens", force: :cascade do |t|
    t.integer "owner_id",   limit: 8,                      null: false
    t.string  "owner_type", limit: 255,   default: "User", null: false
    t.text    "scopes",     limit: 65535
    t.string  "value",      limit: 255,                    null: false
    t.string  "name",       limit: 255,                    null: false
    t.string  "permission", limit: 255,                    null: false
    t.integer "tenant_id",  limit: 8
  end

  add_index "access_tokens", ["owner_id", "owner_type"], name: "idx_auth_tokens_of_user", using: :btree
  add_index "access_tokens", ["value", "owner_id", "owner_type"], name: "idx_value_auth_tokens_of_user", unique: true, using: :btree

  create_table "accounts", force: :cascade do |t|
    t.string   "org_name",                                        limit: 255,                            default: "",    null: false
    t.string   "org_legaladdress",                                limit: 255,                            default: ""
    t.datetime "created_at",                                                                                             null: false
    t.datetime "updated_at"
    t.boolean  "provider",                                                                               default: false
    t.boolean  "buyer",                                                                                  default: false
    t.integer  "country_id",                                      limit: 8
    t.integer  "provider_account_id",                             limit: 8
    t.string   "domain",                                          limit: 255
    t.string   "telephone_number",                                limit: 255
    t.string   "site_access_code",                                limit: 255
    t.string   "credit_card_partial_number",                      limit: 4
    t.date     "credit_card_expires_on"
    t.string   "credit_card_auth_code",                           limit: 255
    t.string   "payment_gateway_type",                            limit: 255
    t.string   "payment_gateway_options",                         limit: 255
    t.boolean  "master"
    t.string   "billing_address_name",                            limit: 255
    t.string   "billing_address_address1",                        limit: 255
    t.string   "billing_address_address2",                        limit: 255
    t.string   "billing_address_city",                            limit: 255
    t.string   "billing_address_state",                           limit: 255
    t.string   "billing_address_country",                         limit: 255
    t.string   "billing_address_zip",                             limit: 255
    t.string   "billing_address_phone",                           limit: 255
    t.string   "org_legaladdress_cont",                           limit: 255
    t.string   "city",                                            limit: 255
    t.string   "state_region",                                    limit: 255
    t.string   "state",                                           limit: 255
    t.boolean  "paid",                                                                                   default: false
    t.datetime "paid_at"
    t.boolean  "signs_legal_terms",                                                                      default: true
    t.string   "timezone",                                        limit: 255
    t.boolean  "delta",                                                                                  default: true,  null: false
    t.string   "from_email",                                      limit: 255
    t.string   "primary_business",                                limit: 255
    t.string   "business_category",                               limit: 255
    t.string   "zip",                                             limit: 255
    t.text     "extra_fields",                                    limit: 65535
    t.string   "vat_code",                                        limit: 255
    t.string   "fiscal_code",                                     limit: 255
    t.decimal  "vat_rate",                                                      precision: 20, scale: 2
    t.text     "invoice_footnote",                                limit: 65535
    t.text     "vat_zero_text",                                   limit: 65535
    t.integer  "default_account_plan_id",                         limit: 8
    t.integer  "default_service_id",                              limit: 8
    t.string   "credit_card_authorize_net_payment_profile_token", limit: 255
    t.integer  "tenant_id",                                       limit: 8
    t.string   "self_domain",                                     limit: 255
    t.string   "service_preffix",                                 limit: 255
    t.string   "s3_prefix",                                       limit: 255
    t.integer  "prepared_assets_version",                         limit: 4
    t.boolean  "sample_data"
    t.integer  "proxy_configs_file_size",                         limit: 4
    t.datetime "proxy_configs_updated_at"
    t.string   "proxy_configs_content_type",                      limit: 255
    t.string   "proxy_configs_file_name",                         limit: 255
    t.string   "support_email",                                   limit: 255
    t.string   "finance_support_email",                           limit: 255
    t.string   "billing_address_first_name",                      limit: 255
    t.string   "billing_address_last_name",                       limit: 255
    t.boolean  "email_all_users",                                                                        default: false
    t.integer  "partner_id",                                      limit: 8
    t.string   "proxy_configs_conf_file_name",                    limit: 255
    t.string   "proxy_configs_conf_content_type",                 limit: 255
    t.integer  "proxy_configs_conf_file_size",                    limit: 4
    t.datetime "proxy_configs_conf_updated_at"
    t.datetime "hosted_proxy_deployed_at"
    t.string   "po_number",                                       limit: 255
    t.datetime "deleted_at"
    t.datetime "state_changed_at"
    t.integer  "first_admin_id",                                  limit: 8
  end

  add_index "accounts", ["default_service_id"], name: "index_accounts_on_default_service_id", using: :btree
  add_index "accounts", ["domain", "deleted_at"], name: "index_accounts_on_domain_and_deleted_at", using: :btree
  add_index "accounts", ["domain", "state_changed_at"], name: "index_accounts_on_domain_and_state_changed_at", using: :btree
  add_index "accounts", ["domain"], name: "index_accounts_on_domain", unique: true, using: :btree
  add_index "accounts", ["master"], name: "index_accounts_on_master", unique: true, using: :btree
  add_index "accounts", ["provider_account_id", "created_at"], name: "index_accounts_on_provider_account_id_and_created_at", using: :btree
  add_index "accounts", ["provider_account_id", "state"], name: "index_accounts_on_provider_account_id_and_state", using: :btree
  add_index "accounts", ["provider_account_id"], name: "index_accounts_on_provider_account_id", using: :btree
  add_index "accounts", ["self_domain", "deleted_at"], name: "index_accounts_on_self_domain_and_deleted_at", using: :btree
  add_index "accounts", ["self_domain", "state_changed_at"], name: "index_accounts_on_self_domain_and_state_changed_at", using: :btree
  add_index "accounts", ["self_domain"], name: "index_accounts_on_self_domain", unique: true, using: :btree
  add_index "accounts", ["state", "deleted_at"], name: "index_accounts_on_state_and_deleted_at", using: :btree
  add_index "accounts", ["state", "state_changed_at"], name: "index_accounts_on_state_and_state_changed_at", using: :btree

  create_table "alerts", force: :cascade do |t|
    t.integer  "account_id",   limit: 8,                             null: false
    t.datetime "timestamp",                                          null: false
    t.string   "state",        limit: 255,                           null: false
    t.integer  "cinstance_id", limit: 8,                             null: false
    t.decimal  "utilization",                precision: 6, scale: 2, null: false
    t.integer  "level",        limit: 4,                             null: false
    t.integer  "alert_id",     limit: 8,                             null: false
    t.text     "message",      limit: 65535
    t.integer  "tenant_id",    limit: 8
    t.integer  "service_id",   limit: 8
  end

  add_index "alerts", ["account_id", "service_id", "state", "cinstance_id"], name: "index_alerts_with_service_id", using: :btree
  add_index "alerts", ["cinstance_id"], name: "index_alerts_on_cinstance_id", using: :btree
  add_index "alerts", ["timestamp"], name: "index_alerts_on_timestamp", using: :btree

  create_table "api_docs_services", force: :cascade do |t|
    t.integer  "account_id",               limit: 8
    t.integer  "tenant_id",                limit: 8
    t.string   "name",                     limit: 255
    t.text     "body",                     limit: 4294967295
    t.text     "description",              limit: 65535
    t.boolean  "published",                                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "system_name",              limit: 255
    t.string   "base_path",                limit: 255
    t.string   "swagger_version",          limit: 255
    t.boolean  "skip_swagger_validations",                    default: false
    t.integer  "service_id",               limit: 8
    t.boolean  "discovered"
  end

  add_index "api_docs_services", ["service_id"], name: "fk_rails_e4d18239f1", using: :btree

  create_table "application_keys", force: :cascade do |t|
    t.integer  "application_id", limit: 8,   null: false
    t.string   "value",          limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",      limit: 8
  end

  add_index "application_keys", ["application_id", "value"], name: "index_application_keys_on_application_id_and_value", unique: true, using: :btree

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id",    limit: 8
    t.string   "auditable_type",  limit: 255
    t.integer  "user_id",         limit: 8
    t.string   "user_type",       limit: 255
    t.string   "username",        limit: 255
    t.string   "action",          limit: 255
    t.integer  "version",         limit: 4,     default: 0
    t.datetime "created_at"
    t.integer  "tenant_id",       limit: 8
    t.integer  "provider_id",     limit: 8
    t.string   "kind",            limit: 255
    t.text     "audited_changes", limit: 65535
    t.text     "comment",         limit: 65535
    t.integer  "associated_id",   limit: 4
    t.string   "associated_type", limit: 255
    t.string   "remote_address",  limit: 255
    t.string   "request_uuid",    limit: 255
  end

  add_index "audits", ["action"], name: "index_audits_on_action", using: :btree
  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["kind"], name: "index_audits_on_kind", using: :btree
  add_index "audits", ["provider_id"], name: "index_audits_on_provider_id", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree
  add_index "audits", ["version"], name: "index_audits_on_version", using: :btree

  create_table "authentication_providers", force: :cascade do |t|
    t.string   "name",                              limit: 255
    t.string   "system_name",                       limit: 255
    t.string   "client_id",                         limit: 255
    t.string   "client_secret",                     limit: 255
    t.string   "token_url",                         limit: 255
    t.string   "user_info_url",                     limit: 255
    t.string   "authorize_url",                     limit: 255
    t.string   "site",                              limit: 255
    t.integer  "account_id",                        limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",                         limit: 8
    t.string   "identifier_key",                    limit: 255, default: "id"
    t.string   "username_key",                      limit: 255, default: "login"
    t.boolean  "trust_email",                                   default: false
    t.string   "kind",                              limit: 255
    t.boolean  "published",                                     default: false
    t.string   "branding_state",                    limit: 255
    t.string   "type",                              limit: 255
    t.boolean  "skip_ssl_certificate_verification",             default: false
    t.string   "account_type",                      limit: 255, default: "developer", null: false
    t.boolean  "automatically_approve_accounts",                default: false
  end

  add_index "authentication_providers", ["account_id", "system_name"], name: "index_authentication_providers_on_account_id_and_system_name", unique: true, using: :btree
  add_index "authentication_providers", ["account_id"], name: "index_authentication_providers_on_account_id", using: :btree

  create_table "backend_api_configs", force: :cascade do |t|
    t.string   "path",           limit: 255, default: ""
    t.integer  "service_id",     limit: 8
    t.integer  "backend_api_id", limit: 8
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "tenant_id",      limit: 8
  end

  add_index "backend_api_configs", ["backend_api_id", "service_id"], name: "index_backend_api_configs_on_backend_api_id_and_service_id", unique: true, using: :btree
  add_index "backend_api_configs", ["path", "service_id"], name: "index_backend_api_configs_on_path_and_service_id", unique: true, using: :btree
  add_index "backend_api_configs", ["service_id"], name: "index_backend_api_configs_on_service_id", using: :btree

  create_table "backend_apis", force: :cascade do |t|
    t.string   "name",             limit: 511,                            null: false
    t.string   "system_name",      limit: 255,                            null: false
    t.text     "description",      limit: 16777215
    t.string   "private_endpoint", limit: 255
    t.integer  "account_id",       limit: 8
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "tenant_id",        limit: 8
    t.string   "state",            limit: 255,      default: "published", null: false
  end

  add_index "backend_apis", ["account_id", "system_name"], name: "index_backend_apis_on_account_id_and_system_name", unique: true, using: :btree
  add_index "backend_apis", ["state"], name: "index_backend_apis_on_state", using: :btree

  create_table "backend_events", id: false, force: :cascade do |t|
    t.integer  "id",         limit: 8,     null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "backend_events", ["id"], name: "index_backend_events_on_id", unique: true, using: :btree

  create_table "billing_locks", primary_key: "account_id", force: :cascade do |t|
    t.datetime "created_at", null: false
  end

  create_table "billing_strategies", force: :cascade do |t|
    t.integer  "account_id",           limit: 8
    t.boolean  "prepaid",                          default: false
    t.boolean  "charging_enabled",                 default: false
    t.integer  "charging_retry_delay", limit: 4,   default: 3
    t.integer  "charging_retry_times", limit: 4,   default: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "numbering_period",     limit: 255, default: "monthly"
    t.string   "currency",             limit: 255, default: "USD"
    t.integer  "tenant_id",            limit: 8
    t.string   "type",                 limit: 255
  end

  add_index "billing_strategies", ["account_id"], name: "index_billing_strategies_on_account_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.integer  "category_type_id", limit: 8
    t.integer  "parent_id",        limit: 8
    t.string   "name",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",       limit: 8
    t.integer  "tenant_id",        limit: 8
  end

  add_index "categories", ["account_id"], name: "index_categories_on_account_id", using: :btree

  create_table "category_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", limit: 8
    t.integer  "tenant_id",  limit: 8
  end

  add_index "category_types", ["account_id"], name: "index_category_types_on_account_id", using: :btree

  create_table "cinstances", force: :cascade do |t|
    t.integer  "plan_id",                  limit: 8,                                                    null: false
    t.integer  "user_account_id",          limit: 8
    t.string   "user_key",                 limit: 256
    t.string   "provider_public_key",      limit: 255
    t.datetime "created_at",                                                                            null: false
    t.datetime "updated_at"
    t.string   "state",                    limit: 255,                                                  null: false
    t.text     "description",              limit: 65535
    t.datetime "paid_until"
    t.string   "application_id",           limit: 255
    t.string   "name",                     limit: 255
    t.datetime "trial_period_expires_at"
    t.decimal  "setup_fee",                              precision: 20, scale: 2, default: 0.0
    t.string   "type",                     limit: 255,                            default: "Cinstance", null: false
    t.text     "redirect_url",             limit: 65535
    t.datetime "variable_cost_paid_until"
    t.text     "extra_fields",             limit: 65535
    t.boolean  "end_user_required"
    t.integer  "tenant_id",                limit: 8
    t.string   "create_origin",            limit: 255
    t.datetime "first_traffic_at"
    t.datetime "first_daily_traffic_at"
    t.integer  "service_id",               limit: 8
    t.datetime "accepted_at"
  end

  add_index "cinstances", ["application_id"], name: "index_cinstances_on_application_id", using: :btree
  add_index "cinstances", ["plan_id"], name: "fk_ct_contract_id", using: :btree
  add_index "cinstances", ["type", "plan_id", "service_id", "state"], name: "index_cinstances_on_type_and_plan_id_and_service_id_and_state", using: :btree
  add_index "cinstances", ["type", "service_id", "created_at"], name: "index_cinstances_on_type_and_service_id_and_created_at", using: :btree
  add_index "cinstances", ["type", "service_id", "plan_id", "state"], name: "index_cinstances_on_type_and_service_id_and_plan_id_and_state", using: :btree
  add_index "cinstances", ["type", "service_id", "state", "first_traffic_at"], name: "idx_cinstances_service_state_traffic", using: :btree
  add_index "cinstances", ["user_account_id"], name: "fk_ct_user_account_id", using: :btree
  add_index "cinstances", ["user_key"], name: "index_cinstances_on_user_key", length: {"user_key"=>255}, using: :btree

  create_table "cms_files", force: :cascade do |t|
    t.integer  "provider_id",             limit: 8,   null: false
    t.integer  "section_id",              limit: 8
    t.integer  "tenant_id",               limit: 8
    t.datetime "attachment_updated_at"
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size",    limit: 8
    t.string   "attachment_file_name",    limit: 255
    t.string   "random_secret",           limit: 255
    t.string   "path",                    limit: 255
    t.boolean  "downloadable"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_files", ["provider_id", "path"], name: "index_cms_files_on_provider_id_and_path", using: :btree
  add_index "cms_files", ["provider_id"], name: "index_cms_files_on_provider_id", using: :btree
  add_index "cms_files", ["section_id"], name: "index_cms_files_on_section_id", using: :btree

  create_table "cms_group_sections", force: :cascade do |t|
    t.integer "group_id",   limit: 8
    t.integer "section_id", limit: 8
    t.integer "tenant_id",  limit: 8
  end

  add_index "cms_group_sections", ["group_id"], name: "index_cms_group_sections_on_group_id", using: :btree

  create_table "cms_groups", force: :cascade do |t|
    t.integer  "tenant_id",   limit: 8
    t.integer  "provider_id", limit: 8,   null: false
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_groups", ["provider_id"], name: "index_cms_groups_on_provider_id", using: :btree

  create_table "cms_permissions", force: :cascade do |t|
    t.integer  "tenant_id",  limit: 8
    t.integer  "account_id", limit: 8
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id",   limit: 8
  end

  add_index "cms_permissions", ["account_id"], name: "index_cms_permissions_on_account_id", using: :btree

  create_table "cms_redirects", force: :cascade do |t|
    t.integer  "provider_id", limit: 8,   null: false
    t.string   "source",      limit: 255, null: false
    t.string   "target",      limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",   limit: 8
  end

  add_index "cms_redirects", ["provider_id", "source"], name: "index_cms_redirects_on_provider_id_and_source", using: :btree
  add_index "cms_redirects", ["provider_id"], name: "index_cms_redirects_on_provider_id", using: :btree

  create_table "cms_sections", force: :cascade do |t|
    t.integer  "provider_id",  limit: 8,                            null: false
    t.integer  "tenant_id",    limit: 8
    t.integer  "parent_id",    limit: 8
    t.string   "partial_path", limit: 255
    t.string   "title",        limit: 255
    t.string   "system_name",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",                   default: true
    t.string   "type",         limit: 255, default: "CMS::Section"
  end

  add_index "cms_sections", ["parent_id"], name: "index_cms_sections_on_parent_id", using: :btree
  add_index "cms_sections", ["provider_id"], name: "index_cms_sections_on_provider_id", using: :btree

  create_table "cms_templates", force: :cascade do |t|
    t.integer  "provider_id",     limit: 8,                        null: false
    t.integer  "tenant_id",       limit: 8
    t.integer  "section_id",      limit: 8
    t.string   "type",            limit: 255
    t.string   "path",            limit: 255
    t.string   "title",           limit: 255
    t.string   "system_name",     limit: 255
    t.text     "published",       limit: 16777215
    t.text     "draft",           limit: 16777215
    t.boolean  "liquid_enabled"
    t.string   "content_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "layout_id",       limit: 8
    t.text     "options",         limit: 65535
    t.string   "updated_by",      limit: 255
    t.string   "handler",         limit: 255
    t.boolean  "searchable",                       default: false
    t.string   "rails_view_path", limit: 255
  end

  add_index "cms_templates", ["provider_id", "path"], name: "index_cms_templates_on_provider_id_and_path", using: :btree
  add_index "cms_templates", ["provider_id", "rails_view_path"], name: "index_cms_templates_on_provider_id_and_rails_view_path", using: :btree
  add_index "cms_templates", ["provider_id", "system_name"], name: "index_cms_templates_on_provider_id_and_system_name", using: :btree
  add_index "cms_templates", ["provider_id", "type"], name: "index_cms_templates_on_provider_id_type", using: :btree
  add_index "cms_templates", ["section_id"], name: "index_cms_templates_on_section_id", using: :btree
  add_index "cms_templates", ["type"], name: "index_cms_templates_on_type", using: :btree

  create_table "cms_templates_versions", force: :cascade do |t|
    t.integer  "provider_id",    limit: 8,                        null: false
    t.integer  "tenant_id",      limit: 8
    t.integer  "section_id",     limit: 8
    t.string   "type",           limit: 255
    t.string   "path",           limit: 255
    t.string   "title",          limit: 255
    t.string   "system_name",    limit: 255
    t.text     "published",      limit: 16777215
    t.text     "draft",          limit: 16777215
    t.boolean  "liquid_enabled"
    t.string   "content_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "layout_id",      limit: 8
    t.integer  "template_id",    limit: 8
    t.string   "template_type",  limit: 255
    t.text     "options",        limit: 65535
    t.string   "updated_by",     limit: 255
    t.string   "handler",        limit: 255
    t.boolean  "searchable",                      default: false
  end

  add_index "cms_templates_versions", ["provider_id", "type"], name: "index_cms_templates_versions_on_provider_id_type", using: :btree
  add_index "cms_templates_versions", ["template_id", "template_type"], name: "by_template", using: :btree

  create_table "configuration_values", force: :cascade do |t|
    t.integer  "configurable_id",   limit: 8
    t.string   "configurable_type", limit: 50
    t.string   "name",              limit: 255
    t.string   "value",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",         limit: 8
  end

  add_index "configuration_values", ["configurable_id", "configurable_type", "name"], name: "index_on_configurable_and_name", unique: true, using: :btree
  add_index "configuration_values", ["configurable_id", "configurable_type"], name: "index_on_configurable", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "code",       limit: 255
    t.string   "name",       limit: 255
    t.string   "currency",   limit: 255
    t.decimal  "tax_rate",               precision: 5, scale: 2, default: 0.0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",  limit: 4
    t.boolean  "enabled",                                        default: true
  end

  add_index "countries", ["code"], name: "index_countries_on_code", using: :btree

  create_table "deleted_objects", force: :cascade do |t|
    t.integer  "owner_id",    limit: 8
    t.string   "owner_type",  limit: 255
    t.integer  "object_id",   limit: 8
    t.string   "object_type", limit: 255
    t.datetime "created_at",              null: false
  end

  add_index "deleted_objects", ["object_type", "object_id"], name: "index_deleted_objects_on_object_type_and_object_id", using: :btree
  add_index "deleted_objects", ["owner_type", "owner_id"], name: "index_deleted_objects_on_owner_type_and_owner_id", using: :btree

  create_table "end_user_plans", force: :cascade do |t|
    t.integer  "service_id", limit: 8,   null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",  limit: 8
  end

  create_table "event_store_events", force: :cascade do |t|
    t.string   "stream",      limit: 255,      null: false
    t.string   "event_type",  limit: 255,      null: false
    t.string   "event_id",    limit: 255,      null: false
    t.text     "metadata",    limit: 16777215
    t.text     "data",        limit: 65535
    t.datetime "created_at",                   null: false
    t.integer  "provider_id", limit: 8
    t.integer  "tenant_id",   limit: 8
  end

  add_index "event_store_events", ["created_at"], name: "index_event_store_events_on_created_at", using: :btree
  add_index "event_store_events", ["event_id"], name: "index_event_store_events_on_event_id", unique: true, using: :btree
  add_index "event_store_events", ["provider_id"], name: "index_event_store_events_on_provider_id", using: :btree
  add_index "event_store_events", ["stream"], name: "index_event_store_events_on_stream", using: :btree

  create_table "features", force: :cascade do |t|
    t.integer  "featurable_id",   limit: 8
    t.string   "name",            limit: 255
    t.text     "description",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "system_name",     limit: 255
    t.boolean  "visible",                       default: true,              null: false
    t.string   "featurable_type", limit: 255,   default: "Service",         null: false
    t.string   "scope",           limit: 255,   default: "ApplicationPlan", null: false
    t.integer  "tenant_id",       limit: 8
  end

  add_index "features", ["featurable_type", "featurable_id"], name: "index_features_on_featurable_type_and_featurable_id", using: :btree
  add_index "features", ["featurable_type"], name: "index_features_on_featurable_type", using: :btree
  add_index "features", ["scope"], name: "index_features_on_scope", using: :btree
  add_index "features", ["system_name"], name: "index_features_on_system_name", using: :btree

  create_table "features_plans", id: false, force: :cascade do |t|
    t.integer "plan_id",    limit: 8,   null: false
    t.integer "feature_id", limit: 8,   null: false
    t.string  "plan_type",  limit: 255, null: false
    t.integer "tenant_id",  limit: 8
  end

  add_index "features_plans", ["plan_id", "feature_id"], name: "index_features_plans_on_plan_id_and_feature_id", using: :btree

  create_table "fields_definitions", force: :cascade do |t|
    t.integer  "account_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "target",     limit: 255
    t.boolean  "hidden",                   default: false
    t.boolean  "required",                 default: false
    t.string   "label",      limit: 255
    t.string   "name",       limit: 255
    t.text     "choices",    limit: 65535
    t.text     "hint",       limit: 65535
    t.boolean  "read_only",                default: false
    t.integer  "pos",        limit: 4
    t.integer  "tenant_id",  limit: 8
  end

  add_index "fields_definitions", ["account_id"], name: "index_fields_definitions_on_account_id", using: :btree

  create_table "forums", force: :cascade do |t|
    t.string  "name",             limit: 255
    t.string  "description",      limit: 255
    t.integer "topics_count",     limit: 4,     default: 0
    t.integer "posts_count",      limit: 4,     default: 0
    t.integer "position",         limit: 4,     default: 0
    t.text    "description_html", limit: 65535
    t.string  "state",            limit: 255,   default: "public"
    t.string  "permalink",        limit: 255
    t.integer "account_id",       limit: 8
    t.integer "tenant_id",        limit: 8
  end

  add_index "forums", ["permalink"], name: "index_forums_on_site_id_and_permalink", using: :btree
  add_index "forums", ["position"], name: "index_forums_on_position_and_site_id", using: :btree

  create_table "gateway_configurations", force: :cascade do |t|
    t.text     "settings",   limit: 65535
    t.integer  "proxy_id",   limit: 8
    t.integer  "tenant_id",  limit: 8
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "gateway_configurations", ["proxy_id"], name: "index_gateway_configurations_on_proxy_id", unique: true, using: :btree

  create_table "go_live_states", force: :cascade do |t|
    t.integer  "account_id", limit: 8
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.text     "steps",      limit: 65535
    t.string   "recent",     limit: 255
    t.boolean  "finished",                 default: false
    t.integer  "tenant_id",  limit: 8
  end

  add_index "go_live_states", ["account_id"], name: "index_go_live_states_on_account_id", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.string   "token",       limit: 255
    t.string   "email",       limit: 255
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",  limit: 8
    t.datetime "accepted_at"
    t.integer  "tenant_id",   limit: 8
    t.integer  "user_id",     limit: 8
  end

  create_table "invoice_counters", force: :cascade do |t|
    t.integer  "provider_account_id", limit: 8,               null: false
    t.string   "invoice_prefix",      limit: 255,             null: false
    t.integer  "invoice_count",       limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invoice_counters", ["provider_account_id", "invoice_prefix"], name: "index_invoice_counters_provider_prefix", unique: true, using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "provider_account_id",    limit: 8
    t.integer  "buyer_account_id",       limit: 8
    t.datetime "paid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "due_on"
    t.string   "pdf_file_name",          limit: 255
    t.string   "pdf_content_type",       limit: 255
    t.integer  "pdf_file_size",          limit: 4
    t.datetime "pdf_updated_at"
    t.date     "period"
    t.date     "issued_on"
    t.string   "state",                  limit: 255,                          default: "open",   null: false
    t.string   "friendly_id",            limit: 255,                          default: "fix",    null: false
    t.integer  "tenant_id",              limit: 8
    t.datetime "finalized_at"
    t.string   "fiscal_code",            limit: 255
    t.string   "vat_code",               limit: 255
    t.decimal  "vat_rate",                           precision: 20, scale: 2
    t.string   "currency",               limit: 4
    t.string   "from_address_name",      limit: 255
    t.string   "from_address_line1",     limit: 255
    t.string   "from_address_line2",     limit: 255
    t.string   "from_address_city",      limit: 255
    t.string   "from_address_region",    limit: 255
    t.string   "from_address_state",     limit: 255
    t.string   "from_address_country",   limit: 255
    t.string   "from_address_zip",       limit: 255
    t.string   "from_address_phone",     limit: 255
    t.string   "to_address_name",        limit: 255
    t.string   "to_address_line1",       limit: 255
    t.string   "to_address_line2",       limit: 255
    t.string   "to_address_city",        limit: 255
    t.string   "to_address_region",      limit: 255
    t.string   "to_address_state",       limit: 255
    t.string   "to_address_country",     limit: 255
    t.string   "to_address_zip",         limit: 255
    t.string   "to_address_phone",       limit: 255
    t.integer  "charging_retries_count", limit: 4,                            default: 0,        null: false
    t.date     "last_charging_retry"
    t.string   "creation_type",          limit: 255,                          default: "manual"
  end

  add_index "invoices", ["buyer_account_id", "state"], name: "index_invoices_on_buyer_account_id_and_state", using: :btree
  add_index "invoices", ["buyer_account_id"], name: "index_invoices_on_buyer_account_id", using: :btree
  add_index "invoices", ["provider_account_id", "buyer_account_id"], name: "index_invoices_on_provider_account_id_and_buyer_account_id", using: :btree
  add_index "invoices", ["provider_account_id"], name: "index_invoices_on_provider_account_id", using: :btree

  create_table "legal_term_acceptances", force: :cascade do |t|
    t.integer  "legal_term_id",      limit: 8
    t.integer  "legal_term_version", limit: 4
    t.string   "resource_type",      limit: 255
    t.integer  "resource_id",        limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",          limit: 8
    t.integer  "account_id",         limit: 8
  end

  add_index "legal_term_acceptances", ["account_id"], name: "index_legal_term_acceptances_on_account_id", using: :btree

  create_table "legal_term_bindings", force: :cascade do |t|
    t.integer  "legal_term_id",      limit: 8
    t.integer  "legal_term_version", limit: 4
    t.string   "resource_type",      limit: 255
    t.integer  "resource_id",        limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scope",              limit: 255
    t.integer  "tenant_id",          limit: 8
  end

  create_table "legal_term_versions", force: :cascade do |t|
    t.integer  "legal_term_id",   limit: 8
    t.integer  "version",         limit: 4
    t.string   "name",            limit: 255
    t.string   "slug",            limit: 255
    t.text     "body",            limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",                          default: false
    t.boolean  "deleted",                            default: false
    t.boolean  "archived",                           default: false
    t.string   "version_comment", limit: 255
    t.integer  "created_by_id",   limit: 8
    t.integer  "updated_by_id",   limit: 8
    t.integer  "tenant_id",       limit: 8
  end

  create_table "legal_terms", force: :cascade do |t|
    t.integer  "version",       limit: 4
    t.integer  "lock_version",  limit: 4,          default: 0
    t.string   "name",          limit: 255
    t.string   "slug",          limit: 255
    t.text     "body",          limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",                        default: false
    t.boolean  "deleted",                          default: false
    t.boolean  "archived",                         default: false
    t.integer  "created_by_id", limit: 8
    t.integer  "updated_by_id", limit: 8
    t.integer  "account_id",    limit: 8
    t.integer  "tenant_id",     limit: 8
  end

  add_index "legal_terms", ["account_id"], name: "index_legal_terms_on_account_id", using: :btree

  create_table "line_items", force: :cascade do |t|
    t.integer  "invoice_id",    limit: 8
    t.string   "name",          limit: 255
    t.string   "description",   limit: 255
    t.decimal  "cost",                      precision: 20, scale: 4, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",          limit: 255,                          default: ""
    t.integer  "metric_id",     limit: 8
    t.datetime "finished_at"
    t.integer  "quantity",      limit: 4
    t.time     "started_at"
    t.integer  "tenant_id",     limit: 8
    t.integer  "contract_id",   limit: 8
    t.string   "contract_type", limit: 255
    t.integer  "cinstance_id",  limit: 4
    t.integer  "plan_id",       limit: 8
  end

  add_index "line_items", ["invoice_id"], name: "index_line_items_on_invoice_id", using: :btree

  create_table "log_entries", force: :cascade do |t|
    t.integer  "tenant_id",   limit: 8
    t.integer  "provider_id", limit: 8
    t.integer  "buyer_id",    limit: 8
    t.integer  "level",       limit: 4,   default: 10
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "log_entries", ["provider_id"], name: "index_log_entries_on_provider_id", using: :btree

  create_table "mail_dispatch_rules", force: :cascade do |t|
    t.integer  "account_id",          limit: 8
    t.integer  "system_operation_id", limit: 8
    t.text     "emails",              limit: 65535
    t.boolean  "dispatch",                          default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",           limit: 8
  end

  add_index "mail_dispatch_rules", ["system_operation_id", "account_id"], name: "index_mail_dispatch_rules_on_system_operation_id_and_account_id", unique: true, using: :btree

  create_table "member_permissions", force: :cascade do |t|
    t.integer  "user_id",       limit: 8
    t.string   "admin_section", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",     limit: 8
    t.binary   "service_ids",   limit: 65535
  end

  create_table "message_recipients", force: :cascade do |t|
    t.integer  "message_id",    limit: 8,                null: false
    t.integer  "receiver_id",   limit: 8,                null: false
    t.string   "receiver_type", limit: 255, default: "", null: false
    t.string   "kind",          limit: 255, default: "", null: false
    t.integer  "position",      limit: 4
    t.string   "state",         limit: 255,              null: false
    t.datetime "hidden_at"
    t.integer  "tenant_id",     limit: 8
    t.datetime "deleted_at"
  end

  add_index "message_recipients", ["message_id", "kind"], name: "index_message_recipients_on_message_id_and_kind", using: :btree
  add_index "message_recipients", ["receiver_id"], name: "idx_receiver_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "sender_id",           limit: 8,     null: false
    t.text     "subject",             limit: 65535
    t.text     "body",                limit: 65535
    t.string   "state",               limit: 255,   null: false
    t.datetime "hidden_at"
    t.string   "type",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "system_operation_id", limit: 8
    t.text     "headers",             limit: 65535
    t.integer  "tenant_id",           limit: 8
    t.string   "origin",              limit: 255
  end

  add_index "messages", ["sender_id", "hidden_at"], name: "index_messages_on_sender_id_and_hidden_at", using: :btree

  create_table "metrics", force: :cascade do |t|
    t.string   "system_name",   limit: 255
    t.text     "description",   limit: 65535
    t.string   "unit",          limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at"
    t.integer  "service_id",    limit: 8
    t.string   "friendly_name", limit: 255
    t.integer  "parent_id",     limit: 8
    t.integer  "tenant_id",     limit: 8
    t.integer  "owner_id",      limit: 8
    t.string   "owner_type",    limit: 255
  end

  add_index "metrics", ["owner_type", "owner_id", "system_name"], name: "index_metrics_on_owner_type_and_owner_id_and_system_name", unique: true, using: :btree
  add_index "metrics", ["owner_type", "owner_id"], name: "index_metrics_on_owner_type_and_owner_id", using: :btree
  add_index "metrics", ["service_id", "system_name"], name: "index_metrics_on_service_id_and_system_name", unique: true, using: :btree
  add_index "metrics", ["service_id"], name: "index_metrics_on_service_id", using: :btree

  create_table "moderatorships", force: :cascade do |t|
    t.integer  "forum_id",   limit: 8
    t.integer  "user_id",    limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",  limit: 8
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.integer  "user_id",     limit: 8
    t.binary   "preferences", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",   limit: 8
  end

  add_index "notification_preferences", ["user_id"], name: "index_notification_preferences_on_user_id", unique: true, using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",     limit: 8
    t.string   "event_id",    limit: 255,  null: false
    t.string   "system_name", limit: 1000
    t.string   "state",       limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",       limit: 1000
  end

  add_index "notifications", ["event_id"], name: "index_notifications_on_event_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "oidc_configurations", force: :cascade do |t|
    t.text     "config",                 limit: 65535
    t.string   "oidc_configurable_type", limit: 255,   null: false
    t.integer  "oidc_configurable_id",   limit: 8,     null: false
    t.integer  "tenant_id",              limit: 8
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "oidc_configurations", ["oidc_configurable_type", "oidc_configurable_id"], name: "oidc_configurable", unique: true, using: :btree

  create_table "onboardings", force: :cascade do |t|
    t.integer  "account_id",              limit: 8
    t.string   "wizard_state",            limit: 255
    t.string   "bubble_api_state",        limit: 255
    t.string   "bubble_metric_state",     limit: 255
    t.string   "bubble_deployment_state", limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "bubble_mapping_state",    limit: 255
    t.string   "bubble_limit_state",      limit: 255
    t.integer  "tenant_id",               limit: 8
  end

  add_index "onboardings", ["account_id"], name: "index_onboardings_on_account_id", using: :btree

  create_table "partners", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "api_key",     limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "system_name", limit: 255
    t.string   "logout_url",  limit: 255
  end

  create_table "payment_details", force: :cascade do |t|
    t.integer  "account_id",                 limit: 8
    t.string   "buyer_reference",            limit: 255
    t.string   "payment_service_reference",  limit: 255
    t.string   "credit_card_partial_number", limit: 255
    t.date     "credit_card_expires_on"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "tenant_id",                  limit: 8
  end

  add_index "payment_details", ["account_id", "buyer_reference"], name: "index_payment_details_on_account_id_and_buyer_reference", using: :btree
  add_index "payment_details", ["account_id", "payment_service_reference"], name: "index_payment_details_on_account_id_and_payment_ref", using: :btree
  add_index "payment_details", ["account_id"], name: "index_payment_details_on_account_id", using: :btree

  create_table "payment_gateway_settings", force: :cascade do |t|
    t.binary   "gateway_settings", limit: 65535
    t.string   "gateway_type",     limit: 255
    t.integer  "account_id",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",        limit: 8
  end

  create_table "payment_transactions", force: :cascade do |t|
    t.integer  "account_id", limit: 8
    t.integer  "invoice_id", limit: 8
    t.boolean  "success",                                           default: false, null: false
    t.decimal  "amount",                   precision: 20, scale: 4
    t.string   "currency",   limit: 4,                              default: "EUR", null: false
    t.string   "reference",  limit: 255
    t.string   "message",    limit: 255
    t.string   "action",     limit: 255
    t.text     "params",     limit: 65535
    t.boolean  "test",                                              default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",  limit: 8
  end

  add_index "payment_transactions", ["invoice_id"], name: "index_payment_transactions_on_invoice_id", using: :btree

  create_table "plan_metrics", force: :cascade do |t|
    t.integer  "plan_id",          limit: 8
    t.integer  "metric_id",        limit: 8
    t.boolean  "visible",                      default: true
    t.boolean  "limits_only_text",             default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "plan_type",        limit: 255,                null: false
    t.integer  "tenant_id",        limit: 8
  end

  add_index "plan_metrics", ["metric_id"], name: "idx_plan_metrics_metric_id", using: :btree
  add_index "plan_metrics", ["plan_id"], name: "idx_plan_metrics_plan_id", using: :btree

  create_table "plans", force: :cascade do |t|
    t.integer  "issuer_id",             limit: 8,                                                   null: false
    t.string   "name",                  limit: 255
    t.string   "rights",                limit: 255
    t.text     "full_legal",            limit: 4294967295
    t.decimal  "cost_per_month",                           precision: 20, scale: 4, default: 0.0,   null: false
    t.integer  "trial_period_days",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",              limit: 4,                                   default: 0
    t.string   "state",                 limit: 255,                                                 null: false
    t.integer  "cancellation_period",   limit: 4,                                   default: 0,     null: false
    t.string   "cost_aggregation_rule", limit: 255,                                 default: "sum", null: false
    t.decimal  "setup_fee",                                precision: 20, scale: 4, default: 0.0,   null: false
    t.boolean  "master",                                                            default: false
    t.integer  "original_id",           limit: 8,                                   default: 0,     null: false
    t.string   "type",                  limit: 255,                                                 null: false
    t.string   "issuer_type",           limit: 255,                                                 null: false
    t.text     "description",           limit: 65535
    t.boolean  "approval_required",                                                 default: false, null: false
    t.boolean  "end_user_required",                                                 default: false, null: false
    t.integer  "tenant_id",             limit: 8
    t.string   "system_name",           limit: 255,                                                 null: false
    t.integer  "partner_id",            limit: 8
    t.integer  "contracts_count",       limit: 4,                                   default: 0,     null: false
  end

  add_index "plans", ["cost_per_month", "setup_fee"], name: "index_plans_on_cost_per_month_and_setup_fee", using: :btree
  add_index "plans", ["issuer_id", "issuer_type", "type", "original_id"], name: "idx_plans_issuer_type_original", using: :btree
  add_index "plans", ["issuer_id"], name: "fk_contracts_service_id", using: :btree

  create_table "policies", force: :cascade do |t|
    t.string   "name",       limit: 255,        null: false
    t.string   "version",    limit: 255,        null: false
    t.binary   "schema",     limit: 4294967295, null: false
    t.integer  "account_id", limit: 8,          null: false
    t.integer  "tenant_id",  limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier", limit: 255
  end

  add_index "policies", ["account_id", "identifier"], name: "index_policies_on_account_id_and_identifier", unique: true, using: :btree
  add_index "policies", ["account_id"], name: "index_policies_on_account_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id",        limit: 8
    t.integer  "topic_id",       limit: 8
    t.text     "body",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id",       limit: 8
    t.text     "body_html",      limit: 65535
    t.string   "email",          limit: 255
    t.string   "first_name",     limit: 255
    t.string   "last_name",      limit: 255
    t.boolean  "anonymous_user",               default: false
    t.integer  "tenant_id",      limit: 8
  end

  add_index "posts", ["created_at", "forum_id"], name: "index_posts_on_forum_id", using: :btree
  add_index "posts", ["created_at", "topic_id"], name: "index_posts_on_topic_id", using: :btree
  add_index "posts", ["created_at", "user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "pricing_rules", force: :cascade do |t|
    t.integer  "metric_id",     limit: 8
    t.integer  "min",           limit: 8,                            default: 1,      null: false
    t.integer  "max",           limit: 8
    t.decimal  "cost_per_unit",             precision: 20, scale: 4, default: 0.0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "plan_id",       limit: 8
    t.string   "plan_type",     limit: 255,                          default: "Plan", null: false
    t.integer  "tenant_id",     limit: 8
  end

  add_index "pricing_rules", ["plan_id", "plan_type"], name: "index_pricing_rules_on_plan_id_and_plan_type", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer  "account_id",          limit: 8,     null: false
    t.string   "oneline_description", limit: 255
    t.text     "description",         limit: 65535
    t.string   "company_url",         limit: 255
    t.string   "blog_url",            limit: 255
    t.string   "rssfeed_url",         limit: 255
    t.string   "email_sales",         limit: 255
    t.string   "email_techsupport",   limit: 255
    t.string   "email_press",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name",      limit: 255
    t.string   "logo_content_type",   limit: 255
    t.integer  "logo_file_size",      limit: 4
    t.string   "state",               limit: 255
    t.string   "company_type",        limit: 255
    t.string   "customers_type",      limit: 255
    t.string   "company_size",        limit: 255
    t.string   "products_delivered",  limit: 255
    t.integer  "tenant_id",           limit: 8
  end

  add_index "profiles", ["account_id"], name: "fk_account_id", using: :btree

  create_table "provided_access_tokens", force: :cascade do |t|
    t.text     "value",      limit: 65535
    t.integer  "user_id",    limit: 8
    t.integer  "tenant_id",  limit: 8
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "provided_access_tokens", ["user_id"], name: "fk_rails_260e99b630", using: :btree

  create_table "provider_constraints", force: :cascade do |t|
    t.integer  "tenant_id",    limit: 8
    t.integer  "provider_id",  limit: 8
    t.integer  "max_users",    limit: 4
    t.integer  "max_services", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "provider_constraints", ["provider_id"], name: "index_provider_constraints_on_provider_id", unique: true, using: :btree

  create_table "proxies", force: :cascade do |t|
    t.integer  "tenant_id",                     limit: 8
    t.integer  "service_id",                    limit: 8
    t.string   "endpoint",                      limit: 255
    t.datetime "deployed_at"
    t.string   "api_backend",                   limit: 255
    t.string   "auth_app_key",                  limit: 255,   default: "app_key"
    t.string   "auth_app_id",                   limit: 255,   default: "app_id"
    t.string   "auth_user_key",                 limit: 255,   default: "user_key"
    t.string   "credentials_location",          limit: 255,   default: "query",                             null: false
    t.string   "error_auth_failed",             limit: 255,   default: "Authentication failed"
    t.string   "error_auth_missing",            limit: 255,   default: "Authentication parameters missing"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "error_status_auth_failed",      limit: 4,     default: 403,                                 null: false
    t.string   "error_headers_auth_failed",     limit: 255,   default: "text/plain; charset=us-ascii",      null: false
    t.integer  "error_status_auth_missing",     limit: 4,     default: 403,                                 null: false
    t.string   "error_headers_auth_missing",    limit: 255,   default: "text/plain; charset=us-ascii",      null: false
    t.string   "error_no_match",                limit: 255,   default: "No Mapping Rule matched",           null: false
    t.integer  "error_status_no_match",         limit: 4,     default: 404,                                 null: false
    t.string   "error_headers_no_match",        limit: 255,   default: "text/plain; charset=us-ascii",      null: false
    t.string   "secret_token",                  limit: 255,                                                 null: false
    t.string   "hostname_rewrite",              limit: 255
    t.string   "oauth_login_url",               limit: 255
    t.string   "sandbox_endpoint",              limit: 255
    t.string   "api_test_path",                 limit: 8192
    t.boolean  "api_test_success"
    t.boolean  "apicast_configuration_driven",                default: true,                                null: false
    t.string   "oidc_issuer_endpoint",          limit: 255
    t.integer  "lock_version",                  limit: 8,     default: 0,                                   null: false
    t.string   "authentication_method",         limit: 255
    t.text     "policies_config",               limit: 65535
    t.string   "oidc_issuer_type",              limit: 255,   default: "keycloak"
    t.string   "error_headers_limits_exceeded", limit: 255,   default: "text/plain; charset=us-ascii"
    t.integer  "error_status_limits_exceeded",  limit: 4,     default: 429
    t.string   "error_limits_exceeded",         limit: 255,   default: "Usage limit exceeded"
    t.string   "staging_domain",                limit: 255
    t.string   "production_domain",             limit: 255
  end

  add_index "proxies", ["service_id"], name: "index_proxies_on_service_id", using: :btree
  add_index "proxies", ["staging_domain", "production_domain"], name: "index_proxies_on_staging_domain_and_production_domain", using: :btree

  create_table "proxy_config_affecting_changes", force: :cascade do |t|
    t.integer  "proxy_id",   limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "proxy_config_affecting_changes", ["proxy_id"], name: "index_proxy_config_affecting_changes_on_proxy_id", unique: true, using: :btree

  create_table "proxy_configs", force: :cascade do |t|
    t.integer  "proxy_id",    limit: 8,                    null: false
    t.integer  "user_id",     limit: 8
    t.integer  "version",     limit: 4,        default: 0, null: false
    t.integer  "tenant_id",   limit: 8
    t.string   "environment", limit: 255,                  null: false
    t.text     "content",     limit: 16777215,             null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "hosts",       limit: 8192
  end

  add_index "proxy_configs", ["proxy_id", "environment", "version"], name: "index_proxy_configs_on_proxy_id_and_environment_and_version", using: :btree
  add_index "proxy_configs", ["proxy_id"], name: "index_proxy_configs_on_proxy_id", using: :btree
  add_index "proxy_configs", ["user_id"], name: "index_proxy_configs_on_user_id", using: :btree

  create_table "proxy_logs", force: :cascade do |t|
    t.integer  "provider_id", limit: 8
    t.integer  "tenant_id",   limit: 8
    t.text     "lua_file",    limit: 16777215
    t.string   "status",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "proxy_rules", force: :cascade do |t|
    t.integer  "proxy_id",           limit: 8
    t.string   "http_method",        limit: 255
    t.string   "pattern",            limit: 255
    t.integer  "metric_id",          limit: 8
    t.string   "metric_system_name", limit: 255
    t.integer  "delta",              limit: 4
    t.integer  "tenant_id",          limit: 8
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at"
    t.text     "redirect_url",       limit: 65535
    t.integer  "position",           limit: 4
    t.boolean  "last",                             default: false
    t.integer  "owner_id",           limit: 8
    t.string   "owner_type",         limit: 255
  end

  add_index "proxy_rules", ["owner_type", "owner_id"], name: "index_proxy_rules_on_owner_type_and_owner_id", using: :btree
  add_index "proxy_rules", ["proxy_id"], name: "index_proxy_rules_on_proxy_id", using: :btree

  create_table "referrer_filters", force: :cascade do |t|
    t.integer  "application_id", limit: 8,   null: false
    t.string   "value",          limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",      limit: 8
  end

  add_index "referrer_filters", ["application_id"], name: "index_referrer_filters_on_application_id", using: :btree

  create_table "service_cubert_infos", force: :cascade do |t|
    t.string   "bucket_id",  limit: 255
    t.integer  "service_id", limit: 8
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "tenant_id",  limit: 8
  end

  create_table "service_tokens", force: :cascade do |t|
    t.integer  "service_id", limit: 8
    t.string   "value",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",  limit: 8
  end

  add_index "service_tokens", ["service_id"], name: "index_service_tokens_on_service_id", using: :btree

  create_table "services", force: :cascade do |t|
    t.integer  "account_id",                     limit: 8,                         null: false
    t.string   "name",                           limit: 255,   default: ""
    t.text     "oneline_description",            limit: 65535
    t.text     "description",                    limit: 65535
    t.text     "txt_api",                        limit: 65535
    t.text     "txt_support",                    limit: 65535
    t.text     "txt_features",                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name",                 limit: 255
    t.string   "logo_content_type",              limit: 255
    t.integer  "logo_file_size",                 limit: 4
    t.string   "state",                          limit: 255,                       null: false
    t.boolean  "intentions_required",                          default: false
    t.string   "draft_name",                     limit: 255,   default: ""
    t.text     "infobar",                        limit: 65535
    t.text     "terms",                          limit: 65535
    t.boolean  "display_provider_keys",                        default: false
    t.string   "tech_support_email",             limit: 255
    t.string   "admin_support_email",            limit: 255
    t.string   "credit_card_support_email",      limit: 255
    t.boolean  "buyers_manage_apps",                           default: true
    t.boolean  "buyers_manage_keys",                           default: true
    t.boolean  "custom_keys_enabled",                          default: true
    t.string   "buyer_plan_change_permission",   limit: 255,   default: "request"
    t.boolean  "buyer_can_select_plan",                        default: false
    t.text     "notification_settings",          limit: 65535
    t.integer  "default_application_plan_id",    limit: 8
    t.integer  "default_service_plan_id",        limit: 8
    t.integer  "default_end_user_plan_id",       limit: 8
    t.boolean  "end_user_registration_required",               default: true,      null: false
    t.integer  "tenant_id",                      limit: 8
    t.string   "system_name",                    limit: 255,                       null: false
    t.string   "backend_version",                limit: 255,   default: "1",       null: false
    t.boolean  "mandatory_app_key",                            default: true
    t.boolean  "buyer_key_regenerate_enabled",                 default: true
    t.string   "support_email",                  limit: 255
    t.boolean  "referrer_filters_required",                    default: false
    t.string   "deployment_option",              limit: 255,   default: "hosted"
    t.string   "kubernetes_service_link",        limit: 255
    t.boolean  "act_as_product",                               default: false
  end

  add_index "services", ["account_id"], name: "idx_account_id", using: :btree
  add_index "services", ["system_name", "account_id"], name: "index_services_on_system_name_and_account_id_and_deleted_at", unique: true, using: :btree

  create_table "settings", force: :cascade do |t|
    t.integer  "account_id",                          limit: 8
    t.string   "bg_colour",                           limit: 255
    t.string   "link_colour",                         limit: 255
    t.string   "text_colour",                         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "menu_bg_colour",                      limit: 255
    t.string   "link_label",                          limit: 255
    t.string   "link_url",                            limit: 255
    t.text     "welcome_text",                        limit: 65535
    t.string   "menu_link_colour",                    limit: 255
    t.string   "content_bg_colour",                   limit: 255
    t.string   "tracker_code",                        limit: 255
    t.string   "favicon",                             limit: 255
    t.string   "plans_tab_bg_colour",                 limit: 255
    t.string   "plans_bg_colour",                     limit: 255
    t.string   "content_border_colour",               limit: 255
    t.boolean  "forum_enabled",                                     default: true
    t.boolean  "app_gallery_enabled",                               default: false
    t.boolean  "anonymous_posts_enabled",                           default: false
    t.boolean  "signups_enabled",                                   default: true
    t.boolean  "documentation_enabled",                             default: true
    t.boolean  "useraccountarea_enabled",                           default: true
    t.text     "refund_policy",                       limit: 65535
    t.text     "privacy_policy",                      limit: 65535
    t.boolean  "monthly_charging_enabled",                          default: true
    t.string   "token_api",                           limit: 255,   default: "default"
    t.boolean  "documentation_public",                              default: true,              null: false
    t.boolean  "forum_public",                                      default: true,              null: false
    t.boolean  "hide_service"
    t.string   "cc_terms_path",                       limit: 255,   default: "/termsofservice"
    t.string   "cc_privacy_path",                     limit: 255,   default: "/privacypolicy"
    t.string   "cc_refunds_path",                     limit: 255,   default: "/refundpolicy"
    t.string   "change_account_plan_permission",      limit: 255,   default: "request",         null: false
    t.boolean  "strong_passwords_enabled",                          default: false
    t.string   "change_service_plan_permission",      limit: 255,   default: "request",         null: false
    t.boolean  "can_create_service",                                default: false,             null: false
    t.string   "spam_protection_level",               limit: 255,   default: "none",            null: false
    t.integer  "tenant_id",                           limit: 8
    t.string   "end_users_switch",                    limit: 255,                               null: false
    t.string   "multiple_applications_switch",        limit: 255,                               null: false
    t.string   "multiple_users_switch",               limit: 255,                               null: false
    t.string   "finance_switch",                      limit: 255,                               null: false
    t.string   "multiple_services_switch",            limit: 255,                               null: false
    t.string   "groups_switch",                       limit: 255,                               null: false
    t.string   "account_plans_switch",                limit: 255,                               null: false
    t.string   "authentication_strategy",             limit: 255,   default: "oauth2",          null: false
    t.string   "janrain_api_key",                     limit: 255
    t.string   "janrain_relying_party",               limit: 255
    t.string   "service_plans_switch",                limit: 255,                               null: false
    t.boolean  "public_search",                                     default: false,             null: false
    t.string   "product",                             limit: 255,   default: "connect",         null: false
    t.string   "branding_switch",                     limit: 255,                               null: false
    t.boolean  "monthly_billing_enabled",                           default: true,              null: false
    t.string   "cms_token",                           limit: 255
    t.string   "cas_server_url",                      limit: 255
    t.string   "sso_key",                             limit: 256
    t.string   "sso_login_url",                       limit: 255
    t.boolean  "cms_escape_draft_html",                             default: true,              null: false
    t.boolean  "cms_escape_published_html",                         default: true,              null: false
    t.string   "heroku_id",                           limit: 255
    t.string   "heroku_name",                         limit: 255
    t.boolean  "setup_fee_enabled",                                 default: false
    t.boolean  "account_plans_ui_visible",                          default: false
    t.boolean  "service_plans_ui_visible",                          default: false
    t.string   "skip_email_engagement_footer_switch", limit: 255,   default: "denied",          null: false
    t.boolean  "end_user_plans_ui_visible",                         default: false
    t.string   "web_hooks_switch",                    limit: 255,   default: "denied",          null: false
    t.string   "iam_tools_switch",                    limit: 255,   default: "denied",          null: false
    t.string   "require_cc_on_signup_switch",         limit: 255,   default: "denied",          null: false
    t.boolean  "enforce_sso",                                       default: false,             null: false
  end

  add_index "settings", ["account_id"], name: "index_settings_on_account_id", unique: true, using: :btree

  create_table "slugs", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "sluggable_type", limit: 50
    t.integer  "sluggable_id",   limit: 8
    t.datetime "created_at"
    t.integer  "sequence",       limit: 4,   default: 1, null: false
    t.integer  "tenant_id",      limit: 8
  end

  add_index "slugs", ["name", "sluggable_type", "sequence"], name: "index_slugs_on_n_s_and_s", using: :btree
  add_index "slugs", ["sluggable_id"], name: "index_slugs_on_sluggable_id", using: :btree

  create_table "sso_authorizations", force: :cascade do |t|
    t.string   "uid",                        limit: 255
    t.integer  "authentication_provider_id", limit: 8
    t.integer  "user_id",                    limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",                  limit: 8
    t.text     "id_token",                   limit: 65535
  end

  add_index "sso_authorizations", ["authentication_provider_id"], name: "index_sso_authorizations_on_authentication_provider_id", using: :btree
  add_index "sso_authorizations", ["user_id"], name: "index_sso_authorizations_on_user_id", using: :btree

  create_table "system_operations", force: :cascade do |t|
    t.string   "ref",         limit: 255
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pos",         limit: 4
    t.integer  "tenant_id",   limit: 4
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 8
    t.integer  "taggable_id",   limit: 8
    t.string   "taggable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",     limit: 8
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 255
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",     limit: 8
    t.integer  "tenant_id",      limit: 8
    t.integer  "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["account_id"], name: "index_tags_on_account_id", using: :btree

  create_table "topic_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id",   limit: 8
    t.integer  "tenant_id",  limit: 8
  end

  add_index "topic_categories", ["forum_id"], name: "index_topic_categories_on_forum_id", using: :btree

  create_table "topics", force: :cascade do |t|
    t.integer  "forum_id",        limit: 8
    t.integer  "user_id",         limit: 8
    t.string   "title",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hits",            limit: 4,   default: 0
    t.boolean  "sticky",                      default: false, null: false
    t.integer  "posts_count",     limit: 4,   default: 0
    t.boolean  "locked",                      default: false
    t.integer  "last_post_id",    limit: 8
    t.datetime "last_updated_at"
    t.integer  "last_user_id",    limit: 8
    t.string   "permalink",       limit: 255
    t.integer  "category_id",     limit: 8
    t.boolean  "delta",                       default: true,  null: false
    t.integer  "tenant_id",       limit: 8
  end

  add_index "topics", ["forum_id", "permalink"], name: "index_topics_on_forum_id_and_permalink", using: :btree
  add_index "topics", ["last_updated_at", "forum_id"], name: "index_topics_on_forum_id_and_last_updated_at", using: :btree
  add_index "topics", ["sticky", "last_updated_at", "forum_id"], name: "index_topics_on_sticky_and_last_updated_at", using: :btree

  create_table "usage_limits", force: :cascade do |t|
    t.integer  "metric_id",  limit: 8
    t.string   "period",     limit: 255
    t.integer  "value",      limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "plan_id",    limit: 8
    t.string   "plan_type",  limit: 255, null: false
    t.integer  "tenant_id",  limit: 8
  end

  add_index "usage_limits", ["metric_id", "plan_id", "period"], name: "index_usage_limits_on_metric_id_and_plan_id_and_period", unique: true, using: :btree
  add_index "usage_limits", ["metric_id"], name: "idx_usage_limits_metric_id", using: :btree
  add_index "usage_limits", ["plan_id"], name: "idx_usage_limits_plan_id", using: :btree

  create_table "user_sessions", force: :cascade do |t|
    t.integer  "user_id",              limit: 8
    t.string   "key",                  limit: 255
    t.string   "ip",                   limit: 255
    t.string   "user_agent",           limit: 255
    t.datetime "accessed_at"
    t.datetime "revoked_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.datetime "secured_until"
    t.integer  "sso_authorization_id", limit: 8
  end

  add_index "user_sessions", ["key"], name: "idx_key", using: :btree
  add_index "user_sessions", ["sso_authorization_id"], name: "index_user_sessions_on_sso_authorization_id", using: :btree
  add_index "user_sessions", ["user_id"], name: "idx_user_id", using: :btree

  create_table "user_topics", force: :cascade do |t|
    t.integer  "user_id",    limit: 8
    t.integer  "topic_id",   limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id",  limit: 8
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",                         limit: 40
    t.string   "email",                            limit: 255
    t.string   "crypted_password",                 limit: 40
    t.string   "salt",                             limit: 40
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at"
    t.string   "remember_token",                   limit: 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",                  limit: 40
    t.datetime "activated_at"
    t.string   "state",                            limit: 255
    t.string   "role",                             limit: 255,   default: ""
    t.string   "lost_password_token",              limit: 255
    t.integer  "posts_count",                      limit: 4,     default: 0
    t.integer  "account_id",                       limit: 8
    t.string   "first_name",                       limit: 255
    t.string   "last_name",                        limit: 255
    t.string   "signup_type",                      limit: 255
    t.string   "job_role",                         limit: 255
    t.datetime "last_login_at"
    t.string   "last_login_ip",                    limit: 255
    t.string   "email_verification_code",          limit: 255
    t.string   "title",                            limit: 255
    t.text     "extra_fields",                     limit: 65535
    t.string   "janrain_identifier",               limit: 255
    t.integer  "tenant_id",                        limit: 8
    t.string   "cas_identifier",                   limit: 255
    t.datetime "lost_password_token_generated_at"
    t.string   "authentication_id",                limit: 255
    t.string   "open_id",                          limit: 255
    t.string   "password_digest",                  limit: 255
  end

  add_index "users", ["account_id"], name: "idx_users_account_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["open_id"], name: "index_users_on_open_id", unique: true, using: :btree
  add_index "users", ["posts_count"], name: "index_site_users_on_posts_count", using: :btree
  add_index "users", ["username"], name: "index_users_on_login", using: :btree

  create_table "web_hooks", force: :cascade do |t|
    t.integer  "account_id",                      limit: 8
    t.string   "url",                             limit: 255
    t.boolean  "account_created_on",                          default: false
    t.boolean  "account_updated_on",                          default: false
    t.boolean  "account_deleted_on",                          default: false
    t.boolean  "user_created_on",                             default: false
    t.boolean  "user_updated_on",                             default: false
    t.boolean  "user_deleted_on",                             default: false
    t.boolean  "application_created_on",                      default: false
    t.boolean  "application_updated_on",                      default: false
    t.boolean  "application_deleted_on",                      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "provider_actions",                            default: false
    t.boolean  "account_plan_changed_on",                     default: false
    t.boolean  "application_plan_changed_on",                 default: false
    t.boolean  "application_user_key_updated_on",             default: false
    t.boolean  "application_key_created_on",                  default: false
    t.boolean  "application_key_deleted_on",                  default: false
    t.boolean  "active",                                      default: false
    t.boolean  "application_suspended_on",                    default: false
    t.integer  "tenant_id",                       limit: 8
    t.boolean  "push_application_content_type",               default: true
    t.boolean  "application_key_updated_on",                  default: false
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
