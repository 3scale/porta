# FIXME: I tried to name this Account::Buyer, but there was some constant clash and it wouldn't load into Account. Michal
module Account::BuyerMethods
  extend ActiveSupport::Concern

  included do

    #TODO: test ALL these associations

    belongs_to :provider_account, :class_name => 'Account', :inverse_of => :buyer_accounts

    #TODO: make buyers only have one account_contract
    has_one :bought_account_contract, class_name:  'AccountContract',
                                      foreign_key: :user_account_id,
                                      dependent:   :destroy,
                                      inverse_of:  :user_account
    #TODO: make buyers only have one account_plan
    has_one :bought_account_plan, :through => :bought_account_contract,
                                  :class_name => 'AccountPlan',
                                  :source => :plan

    # Cinstances of services this account has contracted.
    has_many :bought_cinstances, :class_name  => 'Cinstance',
                                 :foreign_key => :user_account_id,
                                 :dependent   => :destroy

    alias_method :application_contracts, :bought_cinstances

    has_many :contracts, foreign_key: :user_account_id, dependent: :destroy

    module UniqueAssociation
      # Oracle can't do DISTINCT when there are TEXT columns
      # so it can't do unique has many through association on plans
      # The uniq has to be done in ruby. This module is included only when Oracle is used.

      def load
        super.tap { @records&.uniq! }
      end

      class << self
        def to_proc
          -> { System::Database.oracle? ? extending(UniqueAssociation) : uniq }
        end

        delegate :arity, to: :to_proc
      end
    end

    has_many :bought_application_plans, UniqueAssociation, :through => :bought_cinstances, :source => :plan, :class_name => 'ApplicationPlan'

    has_many :bought_service_contracts, :class_name=> 'ServiceContract', :foreign_key => :user_account_id, :dependent => :destroy do
      def ids
        # call association_ids to get ids (it will map records or query database)
        proxy_association.owner.send(proxy_association.reflection.name.to_s.singularize + "_ids")
      end

      def services(state = nil)
        conditions         = {}
        conditions[:state] = state.to_s if state
        contracts          = joins(:service_plan).where(conditions)

        Service.where(id: contracts.select(:issuer_id))
      end

      def accessible_services(state = nil)
        services(state).accessible
      end
    end

    has_many :bought_service_plans, UniqueAssociation, :through => :bought_service_contracts, :source => :plan, :class_name => 'ServicePlan'

    has_many :bought_plans, UniqueAssociation, class_name: 'Plan', through: :contracts, source: :plan

    # CMS permissions
    has_many :permissions, :class_name => 'CMS::Permission'
    has_many :groups, :through => :permissions, :class_name => 'CMS::Group', :source => :group

    def accessible_sections
      groups.map(&:sections).flatten.uniq
    end

    # has_many :accessible_sections, :through => :groups, :class_name => 'CMS::Section', :uniq => true, :source => :group_sections
  end

  #TODO: [multiservice] will be removed
  # The single plan the account has contracted
  def bought_plan
    bought_cinstance.plan
  rescue ActiveRecord::RecordNotFound => error
    System::ErrorReporting.report_error(error)

    ApplicationPlan.new
  end

  BUY_DEPRECATED_WARNING = "Buyer#buy(plan) is deprecated - replace it with Plan#create_contract_with(buyer)"

  # DEPRECATED: legacy method - replace by plan.create_contract_with
  #
  def buy( plan, additional_cinstance_params = nil)
    # ActiveSupport::Deprecation.warn(BUY_DEPRECATED_WARNING, caller)
    plan.create_contract_with(self, additional_cinstance_params)
  end

  # DEPRECATED: legacy method - replace by plan.create_contract_with
  #
  def buy!( plan, additional_cinstance_params = nil)
    # ActiveSupport::Deprecation.warn(BUY_DEPRECATED_WARNING, caller)
    plan.create_contract_with!(self, additional_cinstance_params)
  end

  class ApplicationNotFound < ActiveRecord::RecordNotFound; end

  #TODO: [multiservice] will be removed
  # beware that this method relies on *only* one application_contract
  # The single cinstance the account has contracted
  # REFACTOR: it is a convenience method that only works on master for
  # "normal" accounts
  def bought_cinstance
    bought_cinstances.first or
      fail(ApplicationNotFound, "Cinstance of #{org_name} not found")
  end

  def has_bought_cinstance?
    bought_cinstances.count > 0
  end

  def approval_required?
    bought_account_plan(bought_account_plan.nil?).try!(:approval_required?)
  end

  def available_buyer_groups
    provider_account.provided_groups_for_buyers
  end

  def billing_monthly?
    settings.monthly_billing_enabled?
  end

  def billing_monthly!
    settings.update_attribute(:monthly_billing_enabled, true)
  end

  def not_billing_monthly!
    settings.update_attribute(:monthly_billing_enabled, false)
  end

  def paying_monthly?
    settings.monthly_charging_enabled
  end

  def paying_monthly!
    settings.update_attribute(:monthly_charging_enabled, true)
  end

  def not_paying_monthly!
    settings.update_attribute(:monthly_charging_enabled, false)
  end
end
