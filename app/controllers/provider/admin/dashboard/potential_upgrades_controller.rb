class Provider::Admin::Dashboard::PotentialUpgradesController < Provider::Admin::Dashboard::WidgetController

  def show
    respond_with widget
  end

  protected

  def widget_data
    { items: current_items,
      value: is_set_up_correctly?
    }
  end

  def current_items
    current_upgrades.limit(5)
  end

  def current_upgrades
    usage_limit_violations = UsageLimitViolationsQuery.new(current_account)
    usage_limit_violations.in_range(current_range)
  end

  def is_set_up_correctly?
    usage_limits = current_account
      .application_plans.joins(:usage_limits)
      .grouping{ issuer_id }.unscope(:order)
      .references(:usage_limits).count{ usage_limits.id }

    usage_notifications = current_user.accessible_services.pluck(:id, :notification_settings).to_h

    usage_notifications.any? do |service_id, settings|
      web_provider = settings && settings[:web_provider] || []

      usage_limits.key?(service_id) && web_provider.any?{ |level| level >= Alert::VIOLATION_LEVEL }
    end
  end
end
