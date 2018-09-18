class UsageLimitViolationsQuery
  def initialize(account)
    @account = account
  end

  def usage_limit_violations
    alerts.violations
        .joins(:user_account)
        .grouping { [user_account.id, user_account.org_name ] }
        .ordering { count(id).desc }
        .selecting do
      [ user_account.id.as('account_id'),
        user_account.org_name.as('account_name'),
        count(id).as('alerts_count') ]
    end.extending(AlertConversion)
  end

  def in_range(range)
    usage_limit_violations.where(timestamp: range)
  end

  class UsageLimitViolation
    attr_reader :account_id, :account_name, :alerts_count

    def initialize(account_id:, account_name:, alerts_count:)
      @account_id = account_id
      @account_name = account_name
      @alerts_count = alerts_count
    end

    def account
      ::Account.new { |a| a.assign_attributes(account_attributes, without_protection: true) }
    end

    protected

    def account_attributes
      { 'id' => account_id, 'org_name' => account_name }
    end
  end

  module AlertConversion
    def convert_alert(alert)
      attributes = alert.attributes.except('id')
      UsageLimitViolation.new(**attributes.symbolize_keys)
    end

    def to_a
      super.map(&method(:convert_alert))
    end
  end
  private_constant :AlertConversion

  protected

  def alerts
    @account.buyer_alerts.unscope(:includes).not_deleted
  end
end
