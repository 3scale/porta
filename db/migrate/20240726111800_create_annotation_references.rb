class CreateAnnotationReferences < ActiveRecord::Migration[6.1]
  disable_ddl_transaction! if System::Database.postgres?

  def change
    options = "CHARSET=utf8mb4 COLLATE=utf8mb4_bin" if System::Database.mysql?

    create_table :annotations, options: options do |t|
      t.string :name, index: true, null: false
      t.string :value
      t.references :annotated, polymorphic: true, index: true, null: false
      t.integer :tenant_id

      t.timestamps
    end

    reversible do |direction|
      direction.up do
        self.class.execute_trigger_action(:recreate)
      end
      direction.down do
        self.class.execute_trigger_action(:drop)
      end
    end
  end

  def self.execute_trigger_action(action)
    trigger = System::Database.triggers.detect { |trigger| trigger.name == "annotations_tenant_id" }

    expressions = [trigger.public_send(action)].flatten
    expressions.each(&ActiveRecord::Base.connection.method(:execute))
  end
end
