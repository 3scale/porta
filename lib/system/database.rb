# frozen_string_literal: true

require 'active_support/string_inquirer'

module System
  module Database
    class ConnectionError < ActiveRecord::NoDatabaseError; end
    module_function

    def configuration_specification
      @configuration_specification ||= read_configuration_specification
    end

    def read_configuration_specification
      configurations = Rails.application.config.database_configuration
      resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(configurations)
      spec = ActiveRecord::ConnectionHandling::DEFAULT_ENV.call.to_sym

      resolver.spec(spec)
    end

    def adapter
      adapter_method.match(/^(oracle|postgres|mysql).*/).to_a.last
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

    def postgres?
      adapter_method.postgresql_connection?
    end

    def execute_procedure(name, *params)
      command = postgres? ? 'SELECT' : 'CALL'
      ActiveRecord::Base.connection.execute("#{command} #{name}(#{params.join(',')})")
    end

    # Just adding another connection to the pool so we do not mess up with the primary connection
    # And just forget about it after
    class ConnectionProbe < ActiveRecord::Base
      extend System::Database
      self.table_name = 'accounts'

      class << self
        def connection_config
          spec = configuration_specification.config.dup
          if oracle?
            spec[:password] = ENV.fetch('ORACLE_SYSTEM_PASSWORD') {|key| raise KeyError, "Environment #{key} is mandatory"}
            spec[:username] = 'SYSTEM'
          end
          spec
        end

        def ready?
          pool = establish_connection connection_config
          result = nil
          pool.with_connection do |connection|
            result = connection.select_value(sql_for_readiness).tap { pool.disconnect! }
          end
          result.to_s == '1'
        end

        def sql_for_readiness
          if oracle?
            "SELECT 1 FROM v$database WHERE open_mode = 'READ WRITE'"
          elsif mysql?
            'SELECT 1'
          else
            'SELECT 1'
          end
        end
      end
    end

    def ready?
      config = ConnectionProbe.connection_config
      connection_string = "#{config.fetch(:adapter)}://#{config.fetch(:username)}@#{config.fetch(:host) { 'localhost' }}/#{config.fetch(:database)}"
      if ConnectionProbe.ready?
        puts "Connected to #{connection_string}"
        return true
      else
        puts "Cannot connect to #{connection_string}"
        return false
      end
    rescue ActiveRecord::NoDatabaseError => error # In case of mysql
      puts "Connected, but database does not exist: #{error}"
      true
    rescue StandardError => error
      puts "Connection specification: #{config}"
      puts "Failed to connect to database: #{error} (#{error.class})"

      if (cause = error.cause)
        puts "Caused by: #{cause} (#{cause.class})"
      end
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

    module Definitions
      extend ActiveSupport::Concern

      included do
        @triggers = []
        @procedures = []

        class << self
          attr_reader :triggers, :procedures

          def define(&block)
            @triggers.clear
            @procedures.clear

            class_eval(&block)
          end

          def trigger(name, options = {})
            klass_name = "#{System::Database.adapter_module}::Trigger"
            args = [name, yield]
            if variables = options[:with_variables].presence
              klass_name += 'WithVariables'
              args << variables
            end
            @triggers << klass_name.constantize.new(*args)
          end

          def procedure(name, parameters = {})
            klass_name = "#{System::Database.adapter_module}::Procedure"
            @procedures << klass_name.constantize.new(name, yield, parameters)
          end
        end
      end
    end

    def adapter_module
      case adapter.to_sym
      when :mysql
        require 'system/database/mysql'
        MySQL
      else
        "System::Database::#{adapter.camelize}".constantize
      end
    end

    extend SingleForwardable

    def_delegators :adapter_module, :triggers, :procedures
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
