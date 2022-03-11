ActiveSupport.on_load(:active_record) do
  ActsAsTaggableOn::Tag.class_eval do
    class MissingTenantIdError < StandardError
      def initialize(user)
        super("User #{user.id} is missing tenant_id")
      end
    end

    clear_validators!

    validates :account_id, presence: true
    validates :name, presence: true, uniqueness: { scope: :account_id }, length: { maximum: 255 }

    belongs_to :account

    default_scope do
      tenant_id = find_tenant_id

      if User.current && !tenant_id
        exception = MissingTenantIdError.new(User.current)

        if Rails.env.production?
          System::ErrorReporting.report_error(exception)
        elsif Thread.current[:multitenant]
          raise(exception)
        end
      end

      tenant_id ? where(tenant_id: tenant_id) : all
    end

    class << self

      def create(params)
        tenant_id = find_tenant_id

        super params.reverse_merge(tenant_id: tenant_id, account_id: tenant_id)
      end

      # this should cover all the cases:
      # * user is logged in (has tenant_id)
      # * user is not logged in (but provider was already loaded by middleware)
      def find_tenant_id
        User.tenant_id || Thread.current[:multitenant].try!(:original)
      end
    end
  end
end
