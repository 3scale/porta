# frozen_string_literal: true

class FixTenantIdsTriggersOnNullMaster < ActiveRecord::Migration[5.0]
  def up
    triggers = System::Database.triggers.select { |trigger| trigger.table =~ /\Abackend_apis|log_entries|alerts\z/ }
    ActiveRecord::Base.transaction do
      triggers.each do |trigger|
        expressions = [trigger.public_send(:recreate)].flatten
        expressions.each(&ActiveRecord::Base.connection.method(:execute))
      end
    end
  end
end
