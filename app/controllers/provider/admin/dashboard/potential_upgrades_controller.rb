# frozen_string_literal: true

class Provider::Admin::Dashboard::PotentialUpgradesController < Provider::Admin::Dashboard::WidgetBaseController
  def widget
    @widget ||= Provider::Admin::Dashboards::PotentialUpgradesPresenter.new(
      upgrades: current_upgrades,
      set_up_correctly: set_up_correctly?
    )
  end

  private

  def current_upgrades
    UsageLimitViolationsQuery.new(current_account)
                             .in_range(current_range)
                             .limit(5)
  end

  def set_up_correctly?
    usage_limits = current_account.application_plans
                                  .joins(:usage_limits)
                                  .grouping(&:issuer_id)
                                  .unscope(:order)
                                  .references(:usage_limits)
                                  .count

    usage_notifications = current_user.accessible_services.pluck(:id, :notification_settings).to_h

    usage_notifications.any? do |service_id, settings|
      web_provider = (settings && settings[:web_provider]) || []

      usage_limits.key?(service_id) && web_provider.any? { |level| level >= Alert::VIOLATION_LEVEL }
    end
  end
end
