# frozen_string_literal: true

module System
  module Database
    module Oracle
      class Trigger < ::System::Database::Trigger
        def drop
          <<~SQL
            BEGIN
               EXECUTE IMMEDIATE 'DROP TRIGGER #{name}';
            EXCEPTION
              WHEN OTHERS THEN
                IF SQLCODE != -4080 THEN
                  RAISE;
                END IF;
            END;
          SQL
        end

        def body
          <<~SQL
            DECLARE
              master_id numeric;
            BEGIN
              #{set_master_id}

              IF :new.tenant_id IS NULL THEN
                #{trigger}
              END IF;

            #{exception_handler}
            END;
          SQL
        end

        protected

        def set_master_id
          "master_id := #{master_id}"
        rescue ActiveRecord::RecordNotFound
          <<~SQL
            BEGIN
              SELECT id INTO master_id FROM accounts WHERE master = 1;
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
                DBMS_OUTPUT.PUT_LINE('Could not find tenant_id in #{name}');
          SQL
        end
      end

      class TriggerWithVariables < Trigger
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
              #{set_master_id}

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
end
