class CinstanceMessenger < ContractMessenger

  def setup(cinstance, *)
    super
    @application = cinstance
    @service = cinstance.service

    assign_drops :application => @application,
                 :service     => @service
  end

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
