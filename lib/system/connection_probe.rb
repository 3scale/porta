# frozen_string_literal: true

module System
  module Database
    # Just adding another connection to the pool so we do not mess up with the primary connection
    # And just forget about it after
    class ConnectionProbe < ActiveRecord::Base
      extend System::Database
      self.table_name = 'accounts'

      class << self
        def connection_config
          oracle_system_password = ENV['ORACLE_SYSTEM_PASSWORD']

          configuration_specification.config.dup.tap do |spec|
            if oracle? && oracle_system_password.present?
              spec[:password] = oracle_system_password
              spec[:username] = 'SYSTEM'
            end
          end
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
          # We include "dummy" in the Oracle query to skip FAST DUAL and hit the database.
          return 'SELECT 1, dummy FROM DUAL' if oracle?

          'SELECT 1'
        end
      end
    end
  end
end
