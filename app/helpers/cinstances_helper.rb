module CinstancesHelper
  # Probably a horrible hack...
  def user_key_label(cinstance)
    if cinstance.user_account.provider?
      'Provider Key'
    else
      'User Key'
    end
  end

  def application_friendly_name(cinstance)
    cinstance.name =~ /(application)/i ? cinstance.name : "#{cinstance.name} application"
  end

  def suspend_application_confirmation(cinstance)
    if cinstance.plan.free?
      %{
The application will be suspended and no longer be able to access your API.

Are you sure?}
    else
       %{
The application will be suspended and no longer be able to access your API.

Remember that this is paid application, it will be invoiced and/or charged accordingly. Please do not forget to \
take the appropriate actions fitting your user case (modify/cancel invoices, disable charging for the account, etc.).

Are you sure?}
    end
  end

  def credit_card_required_to_change_plan?(application, plan)
    application.is_a?(Cinstance) &&
      application.app_plan_change_should_request_credit_card? &&
      plan.paid? &&
      current_account.is_charged? && !current_account.credit_card_stored?
  end

  def delete_application_link(application)
    msg = t('api.applications.edit.delete_confirmation', name: j(application.name))
    pf_delete_link_for(provider_admin_application_path(application), confirm: msg, title: 'Delete Application')
  end
end
