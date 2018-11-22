# frozen_string_literal: true

require 'active_support/string_inquirer'
require 'system/database/triggers'
require 'system/database/procedures'
module System
  module Database
    class ConnectionError < ActiveRecord::NoDatabaseError; end
    module_function

    def configuration_specification
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

    def postgresql?
      adapter_method.postgresql_connection?
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
            "SELECT 1 FROM v$pdbs WHERE name COLLATE BINARY_CI = '#{connection_config[:database]}' AND open_mode = 'READ WRITE'"
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
