class CreateEmailConfigurations < ActiveRecord::Migration[5.0]
  def up
    # Use case insensitive collation for emails although by spec local part is sensitive.
    # For practical purposes we don't want to support email with only case differences.
    # Oracle and Postgres don't have case insensitive collations, we will rely on app logic for it.
    collation_ci = case
                 # when System::Database.postgres?
                 #   supported only with version 13+
                 #   { collation: "und-x-icu" }
                 when System::Database.mysql?
                   { collation: "utf8_general_ci" }
                 else
                   {}
                 end

    # Postgres does not support unsigned integers
    port_limit = System::Database.postgres? ? 3 : 2

    create_table :email_configurations do |t|
      t.belongs_to :account
      t.string :email, null: false, index: {unique: true}, **collation_ci
      t.string :domain, **collation_ci
      t.string :user_name
      t.string :password
      t.string :authentication
      t.string :tls
      t.string :openssl_verify_mode
      t.string :address, **collation_ci
      t.integer :port, unsigned: true, limit: port_limit
      t.bigint :tenant_id
      t.timestamps
    end

    self.class.execute_trigger_action(:recreate)
  end

  def down
    self.class.execute_trigger_action(:drop)
    drop_table :email_configurations
  end

  def self.execute_trigger_action(action)
    trigger = System::Database.triggers.detect { |trigger| trigger.name == "email_configurations_tenant_id" }

    expressions = [trigger.public_send(action)].flatten
    expressions.each(&ActiveRecord::Base.connection.method(:execute))
  end
end
