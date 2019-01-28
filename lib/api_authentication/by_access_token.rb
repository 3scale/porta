module ApiAuthentication
  module ByAccessToken
    extend ActiveSupport::Concern

    def current_user
      @current_user ||= authenticated_token.try!(:owner) or defined?(super) && super
    end

    included do
      include ApiAuthentication::HttpAuthentication

      class_attribute :_access_token_scopes, instance_accessor: false
      self._access_token_scopes = []

      before_action :verify_access_token_scopes
      around_action :enforce_access_token_permission
      rescue_from ApiAuthentication::ByAccessToken::Error,
                  with: :show_access_key_permission_error
    end

    module ReadOnlyTransaction
      def read_only_transaction?
        ::ApiAuthentication::ByAccessToken::PermissionEnforcer.read_only?
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
          transaction = ::ApiAuthentication::ByAccessToken::PermissionEnforcer.start_transaction
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

          transaction = ::ApiAuthentication::ByAccessToken::PermissionEnforcer.set_transaction
          execute(transaction) if transaction
        end
      end
    end

    protected

    module ClassMethods
      def authenticate_access_token(status: 401, **options)
        define_method :authenticate! do
          render status: status, **options unless logged_in?
        end
      end

      def access_token_scopes=(*scopes)
        flattened_scopes = scopes.flatten
        validate_scopes!(flattened_scopes)
        self._access_token_scopes = flattened_scopes
      end

      def access_token_scopes
        _access_token_scopes
      end

      def validate_scopes!(scopes)
        available_scopes = AccessToken::SCOPES.values
        invalid_scopes   = scopes.map(&:to_s) - available_scopes

        raise(ScopeError, "scopes #{invalid_scopes} do not exist") if invalid_scopes.any?
      end
    end

    def access_token_scopes
      self.class.access_token_scopes
    end

    def allowed_scopes
      access_token_scopes.map(&:to_s) & user_allowed_scopes
    end

    def show_access_key_permission_error
      self.response_body = nil # prevent double render errors
      render_error "Your access token does not have the correct permissions", status: 403
    end

    def authenticated_token
      return @authenticated_token if instance_variable_defined?(:@authenticated_token)
      @authenticated_token = domain_account.access_tokens.find_from_value(access_token) if access_token
    end

    def enforce_access_token_permission
      PermissionEnforcer.enforce(authenticated_token, &Proc.new)
    end

    def verify_access_token_scopes
      return true unless params[:access_token]

      raise PermissionError if !authenticated_token || allowed_scopes.blank?
      raise ScopeError if (allowed_scopes & authenticated_token.scopes).blank?

      true
    end

    def verify_write_permission
      return true unless params[:access_token]
      raise PermissionError unless authenticated_token.try(:permission) == PermissionEnforcer::READ_WRITE
    end

    Error = Class.new(StandardError)

    ScopeError = Class.new(Error)
    PermissionError = Class.new(Error)


    module PermissionEnforcer

      extend self

      READ_ONLY = 'ro'.freeze
      READ_WRITE = 'rw'.freeze

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

      def enforce(access_token)
        self.level = access_token.try!(:permission)

        return yield unless requires_transaction?

        if connection.transaction_open?
          raise "Can't use read-only Access Token with transactional fixtures" if Rails.env.test?

          error = EnforceError.new("couldn't open new transaction to enforce read-only access token")
          System::ErrorReporting.report_error(error)
        end

        connection.transaction(requires_new: true, &Proc.new)
      rescue ActiveRecord::StatementInvalid => error
        if error.message =~ /read(-|\s)only transaction/i
          fail PermissionError, error.message, caller
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

    private

    def access_token
      @access_token ||= params.fetch(:access_token, &method(:http_authentication))
    end

    def user_allowed_scopes
      @user_allowed_scopes ||= current_user.allowed_access_token_scopes.values
    end
  end
end
