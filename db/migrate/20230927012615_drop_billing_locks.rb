class DropBillingLocks < ActiveRecord::Migration[5.2]
  def up
    drop_table :billing_locks
  end

  def down
    table_opts = System::Database.mysql? ? { options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" } : {}
    datetime_opts = System::Database.oracle? ? { precision: 6 } : {}

    create_table "billing_locks", primary_key: "account_id", force: :cascade, **table_opts do |t|
      t.datetime "created_at", null: false, **datetime_opts
    end
  end
end
