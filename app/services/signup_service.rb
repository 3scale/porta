# frozen_string_literal: true

class SignupService

  attr_reader :provider, :plans, :session, :account_params, :user_params, :authentication_provider

  def initialize(provider:, plans:, session:, account_params:, user_params:, authentication_provider: nil)
    @provider       = provider
    @plans          = plans
    @session        = session
    @account_params = account_params
    @user_params    = user_params.merge(signup_type: :new_signup)
    @authentication_provider = authentication_provider
  end

  def create
    signup_result = Signup::DeveloperAccountManager.new(provider).create(signup_params) do |signup|
      strategy.on_new_user(signup.user, session)
      yield(signup) if block_given?
    end

    if signup_result.persisted?
      signup_result.account_approve! if account_should_be_approved?(signup_result)
      push_webhooks(signup_result.user)
      track_signup
      clear_session
    end

    signup_result
  end

  def self.create(attributes, &block)
    new(attributes).create(&block)
  end

  private

  def account_should_be_approved?(signup_result)
    return false unless authentication_provider
    authentication_provider.automatically_approve_accounts? && !signup_result.account_approved?
  end

  def signup_params
    Signup::SignupParams.new(plans: plans, user_attributes: user_params, account_attributes: account_params)
  end

  def push_webhooks(user)
    webhook_name  = 'created'
    buyer_account = user.account

    buyer_account.web_hook_event!(event: webhook_name)
    user.web_hook_event!(event: webhook_name)

    buyer_account.bought_cinstances.each do |cinstance|
      cinstance.web_hook_event!(event: webhook_name)
    end
  end

  def clear_session
    strategy.on_signup_complete(session)
  end

  def track_signup
    ThreeScale::Analytics.track(provider.first_admin,
                                'Acquired new Developer Account',
                                strategy.track_signup_options(session: session))
  end

  def strategy
    @strategy ||= Authentication::Strategy.build(provider)
  end
end
