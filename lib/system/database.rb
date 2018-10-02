# frozen_string_literal: true

require 'active_support/string_inquirer'

module System
  module Database
    module_function

    def configuration_specification
      configurations = Rails.application.config.database_configuration
      resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(configurations)
      spec = ActiveRecord::ConnectionHandling::DEFAULT_ENV.call.to_sym

      resolver.spec(spec)
    end

    def adapter_method
      ActiveSupport::StringInquirer.new(configuration_specification.adapter_method)
    end

    def oracle?
      adapter_method.oracle_enhanced_connection?
    end

    def mysql?
      adapter_method.mysql2_connection?
    end

    # Just adding another connection to the pool so we do not mess up with the primary connection
    # And just forget about it after
    class ConnectionProbe < ActiveRecord::Base
      extend System::Database
      self.table_name = 'accounts'

      class << self
        def connection_spec
          spec = configuration_specification.config.dup
          if oracle?
            spec['password'] = ENV.fetch('ORACLE_SYSTEM_PASSWORD'){|key| raise KeyError, "Environment #{key} is mandatory"}
            spec['username'] = 'SYSTEM'
          end
          spec
        end

        def ready?
          pool = establish_connection connection_spec
          result = connection.select_value(sql_for_readiness).tap{ pool.disconnect! }
          result.to_s == '1'
        end

        def sql_for_readiness
          case
          when oracle?
            'SELECT 1 FROM V$INSTANCE WHERE "STATUS" = \'OPEN\''
          when mysql?
            'SELECT 1'
          else
            'SELECT 1'
          end
        end
      end
    end

    def ready?
      ConnectionProbe.ready?
    rescue => e
      Rails.logger.debug "Database is not ready, failed with error: #{e.message}"
      false
    end

    module Scopes
      module IdOrSystemName
        def find_by_id_or_system_name!(id_or_system_name)
          by_id_or_system_name(id_or_system_name).first!
        end

        def find_by_id_or_system_name(id_or_system_name)
          by_id_or_system_name(id_or_system_name).first
        end

        def by_id_or_system_name(id_or_system_name)
          where.has do
            scope = (system_name == id_or_system_name)

            begin
              # TODO: tried using TO_NUMBER('n' DEFAULT 0 ON CONVERSION ERROR), but that fails with:
              #   OCIError: ORA-43907: This argument must be a literal or bind variable.
              # Maybe worth trying again on Rails 5.2.
              scope | (id == Integer(id_or_system_name))
            rescue ArgumentError
              scope
            end
          end
        end
      end
    end

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

    class StoredProcedure
      def initialize(name, body, params = {})
        @name = name
        @body = body
        @params = params
      end

      def drop
        raise NotImplementedError
      end

      def create
        raise NotImplementedError
      end

      def recreate
        [drop, create]
      end

      protected

      attr_reader :name, :body, :params

      def params_declaration
        pairs = params.map { |name, type| "#{name} #{type}" }
        "(#{pairs.join(', ')})"
      end

      def signature
        [name, params_declaration].join
      end
    end
    private_constant :StoredProcedure

    class OracleStoredProcedure < StoredProcedure
      def drop
        <<~SQL
          BEGIN
             EXECUTE IMMEDIATE 'DROP PROCEDURE #{name}';
          EXCEPTION
            WHEN OTHERS THEN
              IF SQLCODE != -4043 THEN
                RAISE;
              END IF;
          END;
        SQL
      end

      def create
        <<~SQL
          CREATE PROCEDURE #{signature} AS #{body}
        SQL
      end
    end

    class MySQLStoredProcedure < StoredProcedure
      def drop
        <<~SQL
          DROP PROCEDURE IF EXISTS #{name}
        SQL
      end

      def create
        <<~SQL
          CREATE PROCEDURE #{signature} #{body}
        SQL
      end
    end
  end
end


if System::Database.oracle? && defined?(ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter::DatabaseTasks)
  ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter::DatabaseTasks.class_eval do
    prepend(Module.new do

      def create
        super
        connection.execute "GRANT create trigger TO #{username}"
        connection.execute "GRANT create procedure TO #{username}"
      end

              protected

      def username
        @config['username']
      end
    end)
  end
end
