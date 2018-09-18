module WebHookTestHelpers

  def fires_webhook(resource = nil, event = nil, user = User.current)
    if resource && user
      options = {:user => user}
      options[:event] = event if event
      WebHook::Event.expects(:enqueue).with(@provider, resource, options)
    else
      WebHook::Event.expects(:enqueue)
    end
  end

  #OPTIMIZE: extract this from the web_hook model directly to avoid the duplication
  def hooks_raw
    [ "account_created_on",
      "account_updated_on",
      "account_deleted_on",
      "account_plan_changed_on",
      "user_created_on",
      "user_updated_on",
      "user_deleted_on",
      "application_created_on",
      "application_updated_on",
      "application_deleted_on",
      "application_plan_changed_on",
      "application_user_key_updated_on",
      "application_key_created_on",
      "application_key_deleted_on",
      "application_key_updated_on",
      "application_suspended_on" ]
  end

  #OPTIMIZE: extract this from the web_hook model directly to avoid the duplication
  def hooks
    {
      :account => [ "created", "updated", "deleted", "plan_changed" ],
      :user => [ "created", "updated", "deleted" ],
      :application => [ "created", "updated", "deleted",
                        "plan_changed", "user_key_updated",
                        "key_created", "key_deleted", "key_updated" ] }
  end

  def set_all_hooks(web_hook, value)
    hooks_raw.each do |hook|
      web_hook.send("#{hook}=", value)
    end
    web_hook.save!
  end

  def all_hooks_are_off(web_hook)
    set_all_hooks web_hook, false
  end

  def all_hooks_are_on(web_hook)
    set_all_hooks web_hook, true
  end

  def web_hook_resource(resource_type)
    case resource_type
    when :account then @buyer
    when :user then @user
    when :application then @application
    end
  end

end
