class ContractMessenger < Messenger::Base

  def setup(contract, *)
    @contract = contract
    @provider_account = contract.provider_account
    @user_account = contract.user_account
    @user = @user_account.admins.first
    @plan = contract.plan

    assign_drops :provider_account => Liquid::Drops::Provider.new(@provider_account),
                 :provider         => Liquid::Drops::Provider.new(@provider_account),
                 :user_account     => Liquid::Drops::Account.new(@user_account),
                 :account          => Liquid::Drops::Account.new(@user_account),
                 :user             => Liquid::Drops::User.new(@user),
                 :plan             => Liquid::Drops::Plan.new(@plan)
  end

  def new_contract(contract, options = {})
    message options, 'new_contract',
                     :sender => @user_account,
                     :to     => @provider_account
  end

  def expired_trial_period_notification(contract, options = {})
    message options, 'plan_change',
                     :subject => "#{@provider_account.org_name} API - Trial period expiry",
                     :sender  => @provider_account,
                     :to      => @user_account
  end

  # TODO: plan_change_for_provider
  def plan_change(contract, options = {})
    assign_drops(previous_plan: Liquid::Drops::Plan.new(@contract.old_plan))

    message(options, 'plan_change',
                     :subject => "API System: #{contract.class.model_name.human} plan change",
                     :sender  => @user_account,
                     :to      => @provider_account)
  end

  def plan_change_for_buyer(contract, options = {})
    message options, 'plan_change',
                     :subject => "#{contract.class.model_name.human} plan changed to '#{contract.plan.name}'",
                     :sender  => @provider_account,
                     :to      => @user_account
  end

  def contract_cancellation(contract, options = {})
    message options, 'contract_cancellation',
                     :subject => "API System: #{contract.class.model_name.human} cancelation",
                     :sender  => @user_account,
                     :to      => @provider_account
  end

  def accept(contract, options = {})
    message options, 'plan_change',
                     :sender => @provider_account,
                     :to     => @user_account
  end

  def reject(contract, options = {})
    message options, 'plan_change',
                     :sender => @provider_account,
                     :to     => @user_account
  end

  def suspended(contract, options = {})
    message options, 'contract_suspended',
                     :sender           => @provider_account,
                     :to               => @user_account,
                     :subject          => "API System: #{contract.class.model_name.human} has been suspended"
  end

  private

  def message(options = {}, ref = nil, additional_options = {})
    additional_options.reverse_merge! :system_operation => SystemOperation.for(ref)
    options.reverse_merge! additional_options

    super(options)
  end
end
