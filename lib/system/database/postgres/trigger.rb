# frozen_string_literal: true

module System
  module Database
    module Postgres
      class Trigger < ::System::Database::Trigger
        def initialize(table, trigger)
          super(table, trigger)
          @trigger_procedure = TriggerProcedure.new("tp_#{name}", trigger_procedure_body)
        end

        attr_reader :trigger_procedure

        def drop
          [drop_trigger_only, trigger_procedure.drop].join(';')
        end

        def create
          [trigger_procedure.create, create_trigger_only].join
        end

        def drop_trigger_only
          <<~SQL
            DROP TRIGGER IF EXISTS #{name} ON #{table};
          SQL
        end

        def create_trigger_only
          <<~SQL
            CREATE TRIGGER #{name}
            BEFORE INSERT ON #{table}
            FOR EACH ROW
            EXECUTE PROCEDURE #{trigger_procedure.name}();
          SQL
        end

        protected

        def set_master_id
          "master_id := #{master_id};"
        rescue ActiveRecord::RecordNotFound
          <<~SQL
            BEGIN
              SELECT id INTO STRICT master_id FROM accounts WHERE master = TRUE;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                master_id := NULL;
            END;
          SQL
        end

        def exception_handler
          <<~SQL
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                RAISE EXCEPTION 'Could not find tenant_id in #{name}';
          SQL
        end

        def trigger_procedure_body
          <<~SQL
            DECLARE
              master_id numeric;
            BEGIN
              #{set_master_id}

              IF NEW.tenant_id IS NULL THEN
                #{trigger}
              END IF;

              RETURN NEW;
            #{exception_handler}
            END;
          SQL
        end
      end

      class TriggerWithVariables < Trigger
        def initialize(table, trigger, trigger_variables)
          @trigger_variables = trigger_variables
          super(table, trigger)
        end

        attr_reader :trigger_variables

        def trigger_procedure_body
          <<~SQL
            DECLARE
              master_id numeric;
              #{trigger_variables}
            BEGIN
              #{set_master_id}

              IF NEW.tenant_id IS NULL THEN
                #{trigger}
              END IF;

              RETURN NEW;
            #{exception_handler}
            END;
          SQL
        end
      end
    end
  end
end
