module System
  module Database
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
            <<~SQL
              SELECT 1 FROM v$database WHERE cdb = 'NO' AND open_mode = 'READ WRITE'
              UNION ALL
              SELECT 1 FROM v$pdbs WHERE name COLLATE BINARY_CI = '#{connection_config[:database]}' AND open_mode = 'READ WRITE'
            SQL
          elsif mysql?
            'SELECT 1'
          else
            'SELECT 1'
          end
        end
      end
    end
  end
end
