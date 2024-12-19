# frozen_string_literal: true

module ApiAuthentication

  Error = Class.new(StandardError)

  ScopeError = Class.new(Error)
  PermissionError = Class.new(Error)

  module PermissionEnforcer

    extend self

    READ_ONLY = 'ro'
    READ_WRITE = 'rw'

    def set_transaction
      case level
      when READ_ONLY then 'SET TRANSACTION READ ONLY'
      when READ_WRITE then 'SET TRANSACTION READ WRITE'
      end
    end

    def start_transaction
      case level
      when READ_ONLY then 'START TRANSACTION READ ONLY'
      when READ_WRITE then 'START TRANSACTION READ WRITE'
      end
    end

    class EnforceError < StandardError
    end

    def enforce(access_token, &block)
      self.level = access_token&.permission

      return yield unless requires_transaction?

      if connection.transaction_open?
        raise "Can't use read-only Access Token with transactional fixtures" if Rails.env.test?

        error = EnforceError.new("couldn't open new transaction to enforce read-only access token")
        System::ErrorReporting.report_error(error)
      end

      connection.transaction(requires_new: true, &block)
    rescue ActiveRecord::StatementInvalid => error
      if error.message =~ /read(-|\s)only transaction/i
        raise PermissionError, error.message, caller
      else
        raise
      end
    ensure
      Rails.logger.info "PermissionEnforcer#ensure clear level"
      self.level = nil
    end

    def read_only?
      level == READ_ONLY
    end

    private

    def requires_transaction?
      case level
      when READ_ONLY then true
      when READ_WRITE then false
      end
    end

    THREAD_VARIABLE = :__permission_enforcer_level

    def level=(level)
      Rails.logger.info "PermissionEnforcer: level = #{level}"
      Thread.current[THREAD_VARIABLE] = level
    end

    def level
      Thread.current[THREAD_VARIABLE]
    end

    def connection
      ActiveRecord::Base.connection
    end
  end

  module ConnectorExtensions
    module ReadOnlyTransaction
      def read_only_transaction?
        ::ApiAuthentication::PermissionEnforcer.read_only?
      end
    end

    module ConnectionExtension
      extend ActiveSupport::Concern

      included do
        prepend TransactionMethods
      end

      module TransactionMethods
        include ReadOnlyTransaction

        def begin_db_transaction
          transaction = ::ApiAuthentication::PermissionEnforcer.start_transaction
          transaction ? execute(transaction) : super
        end
      end
    end

    module OracleEnhancedConnectionExtension
      extend ActiveSupport::Concern

      included do
        prepend TransactionMethods
      end

      module TransactionMethods
        include ReadOnlyTransaction

        def begin_db_transaction
          super

          transaction = ::ApiAuthentication::PermissionEnforcer.set_transaction
          execute(transaction) if transaction
        end
      end
    end
  end
end
