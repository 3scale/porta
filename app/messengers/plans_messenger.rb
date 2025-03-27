class PlansMessenger < Messenger::Base

  def setup(application, new_plan)
    @application = application
    @provider = application.provider_account
    @buyer = application.user_account
    @user = @buyer.admins.first
    @plan = new_plan
    @credit_card_url = developer_portal_routes.admin_account_payment_details_url(:host => @provider.external_domain)

    assign_drops :application => @application,
                 :provider         => Liquid::Drops::Provider.new(@provider),
                 :account          => Liquid::Drops::Account.new(@buyer),
                 :user             => Liquid::Drops::User.new(@user),
                 :plan             => Liquid::Drops::Plan.new(@plan),
                 :credit_card_url  => @credit_card_url
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
