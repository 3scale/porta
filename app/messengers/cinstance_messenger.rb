class CinstanceMessenger < ContractMessenger

  def setup(cinstance, *)
    super
    @application = cinstance
    @service = cinstance.service

    assign_drops :application => @application,
                 :service     => @service
  end

  def new_contract(cinstance)
    @_template_name = 'new_application'

    @url = Rails.application.routes.url_helpers.admin_buyers_application_url(cinstance, :host => cinstance.account.provider_account.admin_domain)

    assign_drops :url => @url

    super cinstance, :system_operation => SystemOperation.for('new_app'),
                     :subject => 'API System: New Application submission'
  end
  alias new_application new_contract

  def accept(cinstance)
    super cinstance, :subject => 'API System: Application has been accepted'
  end

  def reject(cinstance)
    super cinstance, :subject => 'API System: Application has been rejected'
  end

  def suspended(cinstance)
    super cinstance, :system_operation => SystemOperation.for('app_suspended'),
                     :subject => 'API System: Application has been suspended'
  end

  def contract_cancellation(cinstance)
    super cinstance, :subject => "API System: Application deletion",
                     :system_operation => SystemOperation.for('cinstance_cancellation')
  end

  def key_created(cinstance, key)
    assign_drops :key => key
    message(:sender           => @provider_account,
            :to               => @user_account,
            :subject          => "Application key has been created",
            :system_operation => SystemOperation.for('key_created'))
  end

  def key_deleted(cinstance, key)
    assign_drops :key => key
    message(:sender           => @provider_account,
            :to               => @user_account,
            :subject          => "Application key has been deleted",
            :system_operation => SystemOperation.for('key_deleted'))
  end
end
