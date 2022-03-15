
class AccountPlan < Plan

  #application_plan association has :dependent => :destroy why this one does not?
  has_many :account_contracts, :foreign_key => :plan_id
  alias contracts account_contracts

  belongs_to :provider, :class_name => 'Account', :foreign_key => :issuer_id, :inverse_of => :account_plans

  before_destroy :destroy_contracts

  # Returns `issuer_id`. See Plan#currency_cache_key
  #

  def currency_cache_key
    self.issuer_id
  end

  def destroy_contracts
    account_contracts.destroy_all
  end

  def provider_account
    provider
  end

  def master?
    issuer.try!(:default_account_plan) == self
  end
end
