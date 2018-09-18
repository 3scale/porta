# frozen_string_literal: true

require_dependency 'system/database'

module System
  module Database
    class OracleTriggerWithVariables < OracleTrigger
      def initialize(table, trigger, trigger_variables)
        super(table, trigger)
        @trigger_variables = trigger_variables
      end

      attr_reader :trigger_variables

      def body
        <<~SQL
          DECLARE
            master_id numeric;
            #{trigger_variables}
          BEGIN
            #{master_id}

            IF :new.tenant_id IS NULL THEN
              #{trigger}
            END IF;

            #{exception_handler}
          END;
        SQL
      end
    end
  end
end
