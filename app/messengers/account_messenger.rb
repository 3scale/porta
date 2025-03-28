class AccountMessenger < Messenger::Base

  def expired_credit_card_notification_for_buyer(buyer)
    @user_account = buyer
    @provider_account = @user_account.provider_account

    assign_basic_drops
    assign_drops account_payment_url: payment_url

    message(:sender   => @provider_account,
            :to       => @user_account,
            :subject  => "#{@provider_account.org_name} API - Credit card expiry")

  end

  private

  def payment_url
    type = @provider_account.payment_gateway_type.try!(:to_sym)

    return '' if type.nil? || type == :bogus
    developer_portal_routes.polymorphic_url([:admin, :account, type.to_sym], host: @provider_account.external_domain)
  end

  def assign_basic_drops
    assign_drops :user_account     => Liquid::Drops::Account.new(@user_account), # deprecated
                 :account          => Liquid::Drops::Account.new(@user_account),
                 :provider_account => Liquid::Drops::Provider.new(@provider_account), # deprecated
                 :provider         => Liquid::Drops::Provider.new(@provider_account)
  end

end
