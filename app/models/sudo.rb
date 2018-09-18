class Sudo
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :errors

  attr_reader :return_path, :user_session, :xhr

  # @param [String] return_path
  # @param [UserSession] user_session
  def initialize(return_path: , user_session: UserSession.null, xhr: false)
    @return_path = return_path.freeze
    @xhr = !!xhr
    @errors = ActiveModel::Errors.new(self)
    @user_session = user_session
    @verifier = Verifier.new(user_session.user)
  end

  def persisted?
    true
  end

  def secure?
    user_session.secured_until && user_session.secured_until >= Time.now
  end

  class Verifier
    attr_reader :authentication_strategy

    def initialize(user)
      @user = user
      @authentication_strategy = Authentication::Strategy::Internal.new(user.account, true)
    end

    def username
      @user.email.presence || @user.username
    end

    def valid?(current_password)
      authentication_strategy.authenticate(username: username, password: current_password)
    end
  end

  def correct_password?(password)
    user = @verifier.valid?(password)
    unless user
      errors.add(:current_password, 'wrong password')
    end
    user
  end

  def secure!(period: )
    user_session.update_column :secured_until, period.from_now
  end
end
