# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
    ActiveRecord::ConnectionAdapters::Mysql2Adapter.class_eval do
      include ApiAuthentication::ByAccessToken::ConnectionExtension
    end
  end

  if defined?(ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter)
    ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.class_eval do
      include ApiAuthentication::ByAccessToken::OracleEnhancedConnectionExtension
    end
  end

  if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
      include ApiAuthentication::ByAccessToken::ConnectionExtension
    end
  end
end
