module Dashboard
  class TopTrafficPresenter
    include ::DashboardTimeRange

    LIMIT = 5

    attr_reader :stats_client, :cinstances

    # @param cinstances [ActiveRecord::Relation]
    # @param stats_client [Stats::Service]
    def initialize(stats_client, cinstances)
      @stats_client = stats_client
      @cinstances   = cinstances
    end

    delegate :as_json, :each, :present?, to: :current_items

    def current_items
      @_current_items ||= begin

        top_traffic_query = TopTrafficQuery.new(stats_client)
        current_data  = top_traffic_query.by_range(range: current_range)
        previous_data = top_traffic_query.by_range(range: previous_range, cache_allowed: true)

        current_ids = current_data.map(&:id)

        # keeps just the ones that were there in previous top N but are missing now
        left_data      = previous_data.take(LIMIT).reject { |app| current_ids.include?(app.id) }
        cinstances     = cinstances_for(current_ids + left_data.map(&:id)).index_by(&:id)
        previous_apps  = previous_data.map.with_index(1) { |app, position| [ app.id, position] }.to_h
        to_application = -> (data) { Application.new(cinstances[data.id]) }

        current = current_data.map(&to_application).map.with_index(1) do |app, position|
          Dashboard::TopTraffic::TopAppPresenter.new(app, position, previous_apps[app.id])
        end

        left = left_data.map(&to_application).map(&Dashboard::TopTraffic::LeftAppPresenter.method(:new))

        current + left
      end
    end

    def preload
      tap { current_items }
    end

    # @param ids [Array<Integer>]
    def cinstances_for(ids)
      cinstances
        .joins(:user_account)
        .selecting{ [user_account.id.as('account_id'), user_account.org_name.as('account_name'), id, name ]}
        .where(id: ids)
    end

    class Application
      attr_reader :application

      delegate :id, :name, :account_name, :account_id, :to_model, to: :application, allow_nil: true

      # @param application [Cinstance]
      def initialize(application)
        @application = application
      end

      def account
        Account.new.tap do |acc|
          acc.id   = account_id
          acc.name = account_name
        end
      end
    end
  end
end
