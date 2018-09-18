class AddProviderAccountDefaultService < ActiveRecord::Migration

  def self.up

    change_table :accounts do |t|
      t.references :default_service
    end
    add_index :accounts, :default_service_id

    execute %{
      UPDATE accounts
        LEFT JOIN services ON services.account_id = accounts.id
        SET default_service_id = services.id
        WHERE services.account_id IS NOT NULL
    }
  end

  def self.down
    remove_column :accounts, :default_service_id
  end
end
