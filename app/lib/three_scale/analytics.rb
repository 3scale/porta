module ThreeScale
  module Analytics
    extend self

    attr_reader :config, :credentials

    @config = ThreeScale.config.fetch(:web_analytics).freeze
    @credentials = ThreeScale::Analytics::Credentials.new(@config)

    # @param [User] user
    def user_tracking(user, **options)
      UserTracking.new(user, **options)
    end
    alias new user_tracking

    # @param [Account] account
    def account_tracking(account)
      user_tracking(account.first_admin)
    end

    # @param [User] user
    # @param [String] event
    # @param [Hash] properties
    def track(user, event, properties = nil)
      new(user).track(event, properties || {})
    end

    def current_user
      user_tracking(User.current)
    end

    # @param [Account] account
    # @param [String] event
    # @param [Hash] properties
    def track_account(account, event, properties = nil)
      # Doing this dance to not pass nil as a param so `track` can use own default value.
      track(account.first_admin, event, *[properties].compact)
    end

    # @param [User] user
    # @param [Hash] properties
    def identify(user, properties = {})
      user_tracking(user).identify(properties)
    end

    # @param [Account] account
    def group(account, properties = {})
      account_tracking(account).group(properties)
    end

    # @param [User] user
    def traits(user)
      user ? new(user).basic_traits : {}
    end
  end
end
