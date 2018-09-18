class AlertMessenger < Messenger::Base

  def setup(alert)
    @alert     = alert
    @cinstance = alert.cinstance
    @account   = @cinstance.user_account
    @provider  = @account.provider_account
    @service   = @cinstance.service

    assign_drops :cinstance   => Liquid::Drops::Application.new(@cinstance), # deprecated
                 :application => Liquid::Drops::Application.new(@cinstance),
                 :account     => Liquid::Drops::Account.new(@account),
                 :buyer       => Liquid::Drops::Account.new(@account), # deprecated
                 :provider    => Liquid::Drops::Provider.new(@provider),
                 :service     => Liquid::Drops::Service.new(@service),
                 :alert       => Liquid::Drops::Alert.new(alert)
  end

  def limit_alert_for_provider(alert)
    @url = app_stats_url_for_provider(@cinstance)
    send_alert(alert, @account)
  end

  def limit_alert_for_buyer(alert)
    @url = developer_portal_routes.buyer_stats_url(host: domain)
    send_alert(alert, @provider)
  end

  def limit_violation_for_provider(alert)
    @url = app_stats_url_for_provider(@cinstance)
    send_violation(alert, @account)
  end

  def limit_violation_for_buyer(alert)
    @url = developer_portal_routes.buyer_stats_url(host: domain)
    send_violation(alert, @provider)
  end

  def limit_alert_for_provider_of_master(alert)
    send_violation_for_provider(alert, @provider)
  end

  def limit_violation_for_provider_of_master(alert)
    send_violation_for_provider(alert, @provider)
  end


  private

  def app_stats_url_for_provider(app)
    app_routes.admin_buyers_stats_application_url(app, :host => self_domain)
  end

  def domain
    @alert.account.provider_account.domain
  end

  def self_domain
    @alert.account.self_domain
  end

  def send_alert(alert, sender)
    prepare_limit_message alert, sender,
                          "Application '#{@cinstance.name}' limit alert - limit usage is above #{alert.level}%"
  end

  def send_violation(alert, sender)
    prepare_limit_message alert, sender,
                          "Application '#{@cinstance.name}' limit violation - limit usage is above #{alert.level}%"
  end

  def send_violation_for_provider(alert, sender)
    prepare_limit_message alert, sender,
                          "Account limit violation - limit usage is above #{alert.level}%"
  end

  def prepare_limit_message(alert, sender, subject)
    assign_drops :url         => @url,
                 :sender      => Liquid::Drops::Account.new(sender)

    message :sender           => sender,
            :to               => alert.account,
            :subject          => subject,
            :system_operation => SystemOperation.for('limit_alerts')
  end

  def self.limit_message_for(alert)
    account = alert.account
    type = if account.buyer?
             :buyer
           elsif account.provider? && account == alert.cinstance.user_account
             # We are sending a message to provider
             # This case is when the provider breaks the limits of Master
             :provider_of_master
           else
             # Takes into account:
             # - sending message to provider. Its buyer is breaking the limits
             # - sending message to master. One of its provider is breaking the limits
             :provider
           end

    public_send "limit_#{alert.kind}_for_#{type}", alert
  end
end
