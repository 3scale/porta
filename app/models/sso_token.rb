class SSOToken
  include ActiveModel::Validations
  include ActiveModel::MassAssignmentSecurity
  include ActiveModel::Serializers::Xml
  include Rails.application.routes.url_helpers

  attr_accessor   :user_id, :username, :expires_in, :redirect_url, :protocol, :account
  attr_accessible :user_id, :username, :expires_in, :redirect_url, :protocol
  attr_reader     :encrypted_token,    :expires_at

  validates :expires_in, :numericality => { :only_integer => true, :greater_than => 30.seconds, :less_than_or_equal_to => 1.day, :allow_nil => true }
  validates :account, :presence => true
  validates :protocol, :inclusion => { :in => ['https', 'http'], :allow_nil => true }

  validate :parsable_redirect_url
  validate :one_of_user_id_or_username_is_required
  validate :account_is_provider_and_user_of_provider, :if => Proc.new {|o| o.account && o.user_id || o.username }

  def initialize attributes = {}
    assign_attributes({:expires_in => 10.minutes, :protocol => 'https'}.merge(attributes))
    @new_record= true
  end

  def save
    return false unless valid?

    begin
      generate_token
      true
    rescue StandardError => error
      logger.info "[SSO Token] --> #{error.message}"
      errors.add :base, :cannot_be_generated
      false
    end
  end

  def new_record?
    @new_record
  end

  def logger
    Rails.logger
  end

  def to_xml options = {}
    xml = options[:builder] || ThreeScale::XML::Builder.new
    xml.sso_url sso_url!
    xml.to_xml
  end

  def assign_attributes values
    sanitize_for_mass_assignment(values, nil).each do |k, v|
      send("#{k}=", v)
    end
  end

  # It will save the object if new and will return the sso_url
  #
  # Default for a provider account is to create an url that works on its buyer side,
  # however, if the provider is also master, host needs to be the provider's admin domain for which we create the URL
  #
  #
  def sso_url! host = nil
    save if new_record?

    params= {
      host: host || account.domain,
      protocol: protocol,
      token: encrypted_token,
      expires_at: expires_at.to_i,
      redirect_url: redirect_url
    }.delete_if{|k,v| v.nil?}
    host.nil? ? DeveloperPortal::Engine.routes.url_helpers.create_session_url(params) : provider_sso_url(params)
  end

  protected

    def generate_token
      @expires_at= Time.now.utc + expires_in.to_i
      @encrypted_token= ThreeScale::SSO::Encryptor.new(account.settings.sso_key, expires_at.to_i).encrypt_token user_id, username
      @new_record= false
    end

  private

    def parsable_redirect_url
      Addressable::URI.parse redirect_url
    rescue
      errors.add :redirect_url, :invalid
    end

    def one_of_user_id_or_username_is_required
      if user_id.nil? && username.nil?
        errors.add :base, :one_of_user_id_or_username_is_required
      end
    end

    def account_is_provider_and_user_of_provider
      unless account.is_a?(Account) && account.provider?
        errors.add :account, :invalid
        return
      end

      # if we have a user-id and we can't find the user for this provider we fail to generate the token
      unless user_id.blank?
        if account.managed_users.find_by_id(user_id).nil?
          errors.add :user_id, :invalid
        end
        return
      end

      if account.managed_users.find_by_username(username).nil?
        errors.add :username, :invalid
      end
    end
end
