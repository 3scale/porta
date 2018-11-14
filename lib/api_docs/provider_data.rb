module ApiDocs
  class ProviderData < AccountData

    def apps
      @apps ||= @account.provided_cinstances.latest.live
    end

    def accounts
      @accounts ||= @account.buyer_accounts.latest
    end

    def admin_ids
      @account.admins.latest.map do |user|
        {:name => user.username, :value => user.id}
      end
    end

    def user_ids
      accounts.map do |account|
        if user = account.admins.first
          {:name => user.username, :value => user.id}
        end
      end.compact
    end

    def account_ids
      accounts.map do |account|
        { :name => account.name,
          :value => account.id }
      end
    end

    PLAN_NAME = ->(plan) { "#{plan.name} | #{plan.service.name}" }
    def application_plan_ids
      @account.application_plans.includes(:service).latest.map do |plan|
        { :name => PLAN_NAME.call(plan),
          :value => plan.id }
      end
    end

    def service_plan_ids
      @account.service_plans.includes(:service).latest.map do |plan|
        { :name => PLAN_NAME.call(plan),
          :value => plan.id }
      end
    end

    def account_plan_ids
      @account.account_plans.latest.map do |plan|
        { :name => plan.name,
          :value => plan.id }
      end
    end

    def service_ids
      @account.services.map do |service|
        { :name => service.name,
          :value => service.id }
      end
    end

    def metrics
      @metrics ||= @account.metrics.includes(:service).top_level
    end

    METRIC_NAME = ->(metric) { "#{metric.friendly_name} | #{metric.service.name}" }
    def metric_names
      metrics.map do |metric|
        { :name  => METRIC_NAME.call(metric),
          :value => metric.name }
      end
    end

    def metric_ids
      metrics.map do |metric|
        { :name  => METRIC_NAME.call(metric),
          :value => metric.id }
      end
    end

    APP_NAME = ->(app) { [app.name, app.service&.name].compact.join(' | ') }
    def application_ids
       apps.map do |app|
        { :name  => APP_NAME.call(app),
          :value => app.id }
       end
    end

    def data_items
      %w(app_keys app_ids application_ids user_keys user_ids account_ids metric_names metric_ids service_ids admin_ids service_plan_ids application_plan_ids account_plan_ids client_ids client_secrets)
    end

  end
end
