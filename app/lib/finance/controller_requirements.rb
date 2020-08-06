# frozen_string_literal: true

module Finance::ControllerRequirements

  protected

  def authorize_finance
    return true unless current_user # to support authentication by provider key
    authorize! :manage, :finance
  end

  def finance_module_required(account = current_account)
    return if account&.billing_strategy && !account&.master_on_premises?
    render_error 'Finance module not enabled for the account', status: :forbidden
  end
end
