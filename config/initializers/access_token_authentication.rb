# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  require "api_authentication.rb"

  if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
    ActiveRecord::ConnectionAdapters::Mysql2Adapter.class_eval do
      include ApiAuthentication::ConnectorExtensions::ConnectionExtension
    end
  end

  if defined?(ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter)
    ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.class_eval do
      include ApiAuthentication::ConnectorExtensions::OracleEnhancedConnectionExtension
    end
  end

  if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
      include ApiAuthentication::ConnectorExtensions::ConnectionExtension
    end
  end
end
