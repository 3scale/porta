# frozen_string_literal: true

class CreateTriggersBackendApis < ActiveRecord::Migration
  # At this point it does not matter if it blocks these tables or not because they are not being used yet anyway

  def up
    self.class.execute_trigger_action(:recreate)
  end

  def down
    self.class.execute_trigger_action(:drop)
  end

  def self.execute_trigger_action(action)
    backend_api_triggers = System::Database.triggers.select { |trigger| trigger.table =~ /\Abackend_api((s)|(_configs))\z/ }
    BackendApi.transaction do
      backend_api_triggers.each do |trigger|
        methods = [trigger.public_send(action)].flatten # [drop] or [drop, create]
        methods.each(&ActiveRecord::Base.connection.method(:execute))
      end
    end
  end

end
