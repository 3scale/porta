# frozen_string_literal: true

module System
  module Database

    class Trigger
      def initialize(table, trigger)
        @table = table
        @name = "#{table}_tenant_id"
        @trigger = trigger
      end

      def drop
        raise NotImplementedError
      end

      def create
        <<~SQL
          CREATE TRIGGER #{name} BEFORE INSERT ON #{table} FOR EACH ROW #{body}
        SQL
      end

      def recreate
        [drop, create]
      end

      protected

      attr_reader :trigger, :name, :table

      def body
        raise NotImplementedError
      end
    end
    private_constant :Trigger

    class OracleTrigger < Trigger
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
            #{master_id}

            IF :new.tenant_id IS NULL THEN
              #{trigger}
            END IF;

            #{exception_handler}
          END;
        SQL
      end

      protected

      def master_id
        "master_id := #{Account.master.id}"
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

    class MySQLTrigger < Trigger

      def drop
        <<~SQL
          DROP TRIGGER IF EXISTS #{name}
        SQL
      end

      def body
        master_id = begin
          Account.master.id
        rescue ActiveRecord::RecordNotFound
          <<~SQL
            (SELECT id FROM accounts WHERE master)
          SQL
        end

        <<~SQL
          BEGIN
            DECLARE master_id numeric;
            IF @disable_triggers IS NULL THEN
              IF NEW.tenant_id IS NULL THEN
                SET master_id = #{master_id};
                #{trigger}
              END IF;
            END IF;
          END;
        SQL
      end
    end

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
