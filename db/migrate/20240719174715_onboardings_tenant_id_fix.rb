# frozen_string_literal: true

class OnboardingsTenantIdFix < ActiveRecord::Migration[6.1]
  def up
    triggers = System::Database.triggers.select { |trigger| trigger.table =~ /\Aonboardings\z/ }
    ActiveRecord::Base.transaction do
      triggers.each do |trigger|
        expressions = [trigger.public_send(:recreate)].flatten
        expressions.each(&ActiveRecord::Base.connection.method(:execute))
      end
    end

    Onboarding.update_all(tenant_id: nil)
  end
end
