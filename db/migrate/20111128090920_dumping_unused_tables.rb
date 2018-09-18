class DumpingUnusedTables < ActiveRecord::Migration
  def self.up
    drop_table :credit_transactions
    drop_table :delayed_jobs
    drop_table :email_messages
    drop_table :exchange_rates
    drop_table :form_fields
    drop_table :ip_geographies
    drop_table :payment_items
    drop_table :search_terms
    drop_table :service_transactions_before_old_service_transactions if table_exists?(:service_transactions_before_old_service_transactions)
    drop_table :themes if table_exists?(:themes)
    drop_table :validators
    drop_table :whitelabel_logos
  end

  def self.down
    create_table "credit_transactions", :force => true do |t|
      t.integer  "account_id"
      t.string   "kind",                                                 :default => "incoming"
      t.string   "currency",                                             :default => "EUR",      :null => false
      t.decimal  "amount",                :precision => 10, :scale => 2, :default => 0.0,        :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "paypal_transaction_id",                                :default => "",         :null => false
    end
    add_index "credit_transactions", ["paypal_transaction_id"], :name => "index_credit_transactions_on_paypal_transaction_id"

    create_table "delayed_jobs", :force => true do |t|
      t.integer  "priority",   :default => 0
      t.integer  "attempts",   :default => 0
      t.text     "handler"
      t.text     "last_error"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string   "locked_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

    create_table "email_messages", :force => true do |t|
      t.string   "sender"
      t.text     "recipients"
      t.text     "subject"
      t.text     "cc"
      t.text     "bcc"
      t.text     "body"
      t.string   "content_type"
      t.datetime "delivered_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "exchange_rates", :force => true do |t|
      t.string   "source_currency"
      t.string   "target_currency"
      t.float    "rate"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "exchange_rates", ["source_currency", "target_currency", "created_at"], :name => "exchange_rates_index"

    create_table "form_fields", :force => true do |t|
      t.integer "account_id"
      t.text    "fieldsets"
    end
    add_index "form_fields", ["account_id"], :name => "index_form_fields_on_account_id"

    create_table "ip_geographies", :force => true do |t|
      t.string   "host_name"
      t.string   "lng"
      t.string   "lat"
      t.string   "country_code"
      t.string   "state"
      t.string   "city"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "ip",           :limit => 15
    end
    add_index "ip_geographies", ["ip"], :name => "index_ip_geographies_on_client_ip"

    create_table "payment_items", :force => true do |t|
      t.integer  "cinstance_id"
      t.decimal  "cost",                   :precision => 20, :scale => 4
      t.datetime "period_start"
      t.datetime "period_end"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "pricing_rules_snapshot"
      t.string   "currency"
    end

    create_table "search_terms", :force => true do |t|
      t.string   "term"
      t.integer  "user_id"
      t.string   "ip_address"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "service_transactions_before_old_service_transactions", :force => true do |t|
      t.integer  "cinstance_id"
      t.datetime "created_at",                 :null => false
      t.datetime "confirmed_at"
      t.string   "key",          :limit => 64
    end
    add_index "service_transactions_before_old_service_transactions", ["cinstance_id"], :name => "index_transactions_on_cinstance_id"
    add_index "service_transactions_before_old_service_transactions", ["key"], :name => "index_service_transactions_on_key", :unique => true

    create_table "themes", :force => true do |t|
      t.string   "title"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "validators", :force => true do |t|
      t.integer "account_id"
      t.string  "model_class"
      t.string  "attribute"
      t.boolean "required",    :default => false, :null => false
    end
    add_index "validators", ["account_id"], :name => "index_validators_on_account_id"

    create_table "whitelabel_logos", :force => true do |t|
      t.integer  "parent_id"
      t.string   "content_type"
      t.string   "filename"
      t.string   "thumbnail"
      t.integer  "size"
      t.integer  "width"
      t.integer  "height"
      t.integer  "account_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
