module Contract::Billing
  extend ActiveSupport::Concern

  # TODO: remove this method
  #
  # Fetches org_name of cinstance buyer
  def user_name
    user_account.org_name
  end

  # TODO: this should not be here at all ...
  #
  #  Currency the costs of this cinstance are in. Delegates to provider account's
  # currency.
  delegate :currency, to: :provider_account

  # TODO: remove
  def credit_card_missing?
    # REFACTOR: REMOVE
    return false unless provider_account.billing_strategy.try!(:needs_credit_card?)
    return false if     plan.free?
    return false if     trial?

    !user_account.credit_card_stored?
  end
end
