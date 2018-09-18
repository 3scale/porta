class AccountMessenger < Messenger::Base

  def new_signup(account)
    @user_account = account
    @user = account.admins.first
    @provider_account = @user_account.provider_account
    #multiservice
    @service = @provider_account.accessible_services.default

    assign_basic_drops
    assign_drops :service => Liquid::Drops::Service.deprecated(@service), # don't use service in signup template
                 :user    => @user

    message(:sender           => @user_account,
            :to               => @provider_account,
            :subject          => 'API System: New Account Signup',
            :system_operation => SystemOperation.for('user_signup'))
  end

  # This is call by master, sending notifications to providers.
  # Those messages are liquid thus using developer_portal, where we don't have access to System::Application. routes
  def invoices_to_review(provider)
    finalized_url = app_routes.polymorphic_url([:admin, :finance, :invoices], :state => :finalized, :host => provider.admin_domain)

    assign_drops  :provider => Liquid::Drops::Provider.new(provider),
                  :url => finalized_url

    message(:sender => provider.provider_account,
            :to => provider,
            :subject => 'API System: Invoices to review')
  end

  def expired_credit_card_notification_for_buyer(buyer)
    @user_account = buyer
    @provider_account = @user_account.provider_account

    assign_basic_drops
    assign_drops account_payment_url: payment_url

    message(:sender   => @provider_account,
            :to       => @user_account,
            :subject  => "#{@provider_account.org_name} API - Credit card expiry")

  end

  def expired_credit_card_notification_for_provider(buyer)
    @user_account = buyer
    @provider_account = @user_account.provider_account

    assign_basic_drops

    message(:sender  => @user_account,
            :to      => @provider_account,
            :subject => "API System: User Credit card expiry")

  end

  def plan_change_request(buyer, plan)
    @user_account = buyer
    @provider_account = @user_account.provider_account
    @plan = plan

    assign_basic_drops
    assign_drops :plan => Liquid::Drops::Plan.new(@plan)

    message(:sender  => @user_account,
            :to      => @provider_account,
            :subject => "API System: Plan change request")
  end

  private

  def payment_url
    type = @provider_account.payment_gateway_type.try!(:to_sym)

    return '' if type.nil? || type == :bogus
    developer_portal_routes.polymorphic_url([:admin, :account, type.to_sym], host: @provider_account.domain)
  end

  def assign_basic_drops
    assign_drops :user_account     => Liquid::Drops::Account.new(@user_account), # deprecated
                 :account          => Liquid::Drops::Account.new(@user_account),
                 :provider_account => Liquid::Drops::Provider.new(@provider_account), # deprecated
                 :provider         => Liquid::Drops::Provider.new(@provider_account)
  end

end
