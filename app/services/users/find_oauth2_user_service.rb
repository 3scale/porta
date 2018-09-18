class Users::FindOauth2UserService

  Result = Struct.new(:user, :error_message)

  # @return [Result]
  def self.run(oauth_data, auth_provider, scoped_users)
    new(oauth_data, auth_provider, scoped_users).find
  end

  # @param [ThreeScale::OAuth2::UserData] user_data
  # @param [AuthenticationProvider] auth_provider
  # @param [ActiveRecord::Relation] scoped_users
  def initialize(user_data, auth_provider, scoped_users)
    @uid = user_data.uid
    @authentication_id = user_data.authentication_id
    @confirmed_email = user_data.verified_email
    @email = user_data.email
    @auth_provider = auth_provider
    @scoped_users = scoped_users
  end

  # @return [Result]
  def find
    find_by_uid.user ? find_by_uid : find_by_email
  end

  private

  # @return [Result]
  def find_by_email
    email_user = scoped_users.find_by(email: email)
    return Result.new unless email_user

    if confirmed_email.blank?
      Result.new(nil, 'User cannot be authenticated by not verified email address.')
    else
      Result.new(email_user)
    end
  end

  # @return [Result]
  def find_by_uid
    @find_by_uid ||= Result.new((find_by_sso_authorization || find_by_authentication_id))
  end

  def find_by_sso_authorization
    return if uid.blank?
    SSOAuthorization.find_by(authentication_provider: auth_provider,
                             uid: uid, user: scoped_users).try(:user)
  end

  def find_by_authentication_id
    return if authentication_id.blank?
    scoped_users.find_by(authentication_id: authentication_id)
  end

  attr_reader :uid, :authentication_id, :confirmed_email, :email, :auth_provider, :scoped_users
end
