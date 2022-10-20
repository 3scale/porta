# frozen_string_literal: true

class Provider::Admin::PotentialUpgradesPresenter
  include System::UrlHelpers.system_url_helpers
  include DashboardTimeRange

  def initialize(current_account:, current_user:)
    @current_account = current_account
    @current_user = current_user
  end

  attr_reader :current_account, :current_user

  def dashboard_widget_data
    {
      violations: current_violations,
      incorrectSetUp: (!set_up_correctly? && current_account.accessible_services.any?),
      links: {
        adminServiceApplicationPlans: any_services? ? admin_service_application_plans_path(service) : '',
        settingsAdminService: any_services? ? settings_admin_service_path(service, anchor: 'web_provider') : ''
      }
    }
  end

  private

  def service
    @service ||= current_account.accessible_services.first
  end

  def any_services?
    current_account.accessible_services.any?
  end

  # smells like :reek:NestedIterators because of the double any?
  def set_up_correctly?
    usage_notifications = current_user.accessible_services.pluck(:id, :notification_settings).to_h

    usage_notifications.any? do |service_id, settings|
      web_provider = settings.to_h.fetch(:web_provider, [])

      usage_limits.key?(service_id) && web_provider.any? { |level| level >= Alert::VIOLATION_LEVEL }
    end
  end

  def usage_limits
    current_account
      .application_plans.joins(:usage_limits)
      .grouping { issuer_id }
      .unscope(:order)
      .references(:usage_limits)
      .count(:id)
  end

  def current_violations
    usage_limit_violations.limit(5).map do |violation|
      violation.attributes.merge(
        url: admin_alerts_path(
          search: { level: 100, timestamp: [current_range.begin, current_range.end], account_id: violation.account_id }
        )
      )
    end
  end

  def usage_limit_violations
    usage_limit_violations = UsageLimitViolationsQuery.new(current_account)
    usage_limit_violations.in_range(current_range)
  end
end
