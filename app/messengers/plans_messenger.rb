class PlansMessenger < Messenger::Base

  def setup(application, new_plan)
    @application = application
    @provider = application.provider_account
    @buyer = application.user_account
    @user = @buyer.admins.first
    @plan = new_plan
    @credit_card_url = developer_portal_routes.admin_account_payment_details_url(:host => @provider.domain)

    assign_drops :application => @application,
                 :provider         => Liquid::Drops::Provider.new(@provider),
                 :account          => Liquid::Drops::Account.new(@buyer),
                 :user             => Liquid::Drops::User.new(@user),
                 :plan             => Liquid::Drops::Plan.new(@plan),
                 :credit_card_url  => @credit_card_url
  end

  def plan_change_request(application, new_plan)
    @buyer = application.user_account
    @plan = new_plan

    url = app_routes.admin_service_application_url(application.service, application, host: application.account.provider_account.admin_domain)
    # Pending: Create a view for the body.
    body = %|#{@buyer.org_name} are requesting to have their plan changed to #{@plan.name} for application #{application.name}. You can do this from the application page: #{url}|

    message(:sender           => @buyer,
            :to               => @plan.issuer.account,
            :subject          => 'API System: Plan change request',
            :body             => body,
            :system_operation => SystemOperation.for('plan_change_request'))

  end

  def plan_change_request_made(application, new_plan)
    @_template_name = 'plan_change_request_made'
    # This is a paid plan. You can update your payment details <%= link_to "here", payment_details_path %>.</p>
    message(:sender           => @provider,
            :to               => @buyer,
            :subject          => 'Plan change request has been received',
            :system_operation => SystemOperation.for('plan_change_request'))

  end

end
