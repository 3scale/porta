class AuthenticationProvider::GitHub < AuthenticationProvider
  self.authorization_scope = :branding

  after_initialize :set_defaults, unless: :persisted?

  state_machine :branding_state, initial: :initial_state.to_proc do
    state :threescale_branded do
      def oauth_config_required?
        false
      end
    end

    state :custom_branded do
      def oauth_config_required?
        true
      end
    end

    event :custom_brand do
      transition threescale_branded: :custom_branded, if: :client_id_and_client_secret?
    end

    event :brand_as_threescale do
      transition custom_branded: :threescale_branded
    end
  end

  # @return [Account] the account that handles the callback
  def callback_account
    threescale_branded? ? Account.master : account
  end

  def authorization_scope(action_name = nil)
    case action_name
    when 'new', 'update' then super unless threescale_branded?
    when 'show' then nil
    else super
    end
  end

  def set_defaults
    self.published = true if self.class.branded_available?
    super
  end

  def initial_state
    self.class.branded_available? ? :threescale_branded : :custom_branded
  end

  def credentials
    case branding_state.to_sym
    when :threescale_branded
        config = ThreeScale::OAuth2.config.fetch(kind, {}).symbolize_keys

        AuthenticationProvider::Credentials.new(config.fetch(:client_id) { client_id.presence },
                                                config.fetch(:client_secret) { client_secret.presence })
    else super
    end
  end
end
