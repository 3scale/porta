# frozen_string_literal: true

module Pdf
  class Data

    include ERB::Util

    def initialize(account, service, options)
      raise ArgumentError,'No period supplied' unless options[:period]

      @account = account
      @service = service
      @period = options[:period]
      @hit_metric = @service.metrics.hits
      @source = Stats::Service.new(@service)

      @options = {
        :period => @period,
        :metric_name => @hit_metric&.name,
        :since => 1.send(@period).ago.strftime("%Y-%m-%d"),
        :timezone => @account.timezone
      }
    end

    def latest_users(count)
      latest_cinstances = Cinstance.select(:user_account_id).distinct
        .from(@service.cinstances.latest(count), Cinstance.table_name)

      # we want only distinct accounts with cinstance from this service, so fetch them
      buyers = @account.buyer_accounts
                 .where(id: latest_cinstances)
                 .reorder(created_at: :desc)
      buyers.map do |account|
        # because account can have multiple cinstances from multiple services, scope them by service and find last one
        cinstance = account.bought_cinstances.by_service(@service).latest.first or next
        [
          account.org_name,
          account.created_at,
          account.users.first&.email,
          cinstance.plan.name
        ]
      end.compact
    end

    def cinstances_change
      @service.cinstances.where('`cinstances`.created_at > ?',1.send(@period).ago.beginning_of_day).count
    end

    def top_users
      return unless @hit_metric

      options = {:metric => @hit_metric, :period => @period, :timezone => @account.timezone,
                 :since => 1.send(@period).ago, :limit => 5}
      apps = @source.top_clients(options)[:applications] || []
      apps.each_with_object([]) do |entry, memo|
        next if entry[:id].nil? # there are some data inconsistencies in our dbs
        cinstance = @service.cinstances.find(entry[:id])

        memo << [cinstance.user_account.org_name, entry[:value]]
      end
    end

    def users
      @service.published_plans.map { |plan| [plan.name, plan.cinstances.count] }
    end

    def metrics
      data = @source.usage_progress_for_all_metrics(@options)[:metrics]
      data.inject([]) do |row, (metric, stats)|
        percentage = '%0.2f %%' % metric[:data][:change]
        row << [metric[:name], metric[:data][:total], percentage]
      end
    end

    def usage
      @source.usage(@options) unless @hit_metric.nil?
    end

    private

    def sanitize_text(text)
      EscapeUtils.escape_javascript(text.to_s)
    end
  end
end
