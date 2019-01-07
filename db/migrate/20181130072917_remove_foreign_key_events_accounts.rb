# frozen_string_literal: true

class RemoveForeignKeyEventsAccounts < ActiveRecord::Migration
  def up
    return unless foreign_keys(:event_store_events).detect {|fk| fk.column == 'provider_id' }

    remove_foreign_key :event_store_events, column: :provider_id
  end

  def down
    return if foreign_keys(:event_store_events).detect {|fk| fk.column == 'provider_id' }

    add_foreign_key :event_store_events, :accounts, column: :provider_id, on_delete: :cascade
  end
end
