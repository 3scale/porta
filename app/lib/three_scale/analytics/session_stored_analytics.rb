module ThreeScale
  module Analytics
    class SessionStoredAnalytics < Struct.new(:session)
      DELAYED_SESSION_KEY = :__session_stored_analytics
      TRAITS_SESSION_KEY = :__analytics_traits

      # Enqueue calls in a session and retrieve them later.
      # Ideal for calling analytics after redirect.
      #
      # @example Enqueue analytics
      #   analytics_session.delayed.alias(@user.id)
      #   analytics_session.delayed.identify(@user.id, { name: 'Full Name '})
      #
      # @example Dequeue analytics in ERB
      #   <%- while event = analytics_session.shift -%>
      #   <%- name, *args = event -%>
      #     analytics.<%= name %>(<%= args.map(&:to_json).join(', ') %>);
      #   <%- end -%>
      #

      attr_reader :traits

      def initialize(*)
        super
        @delayed_store = (session[DELAYED_SESSION_KEY] ||= [])
        @traits = (session[TRAITS_SESSION_KEY] ||= {})
      end

      def identify(properties)
        @traits.merge!(properties)
      end

      # @return [Delayed] returns proxy object that enqueues method calls to session
      def delayed
        @delayed ||= Delayed.new(@delayed_store)
      end

      # @return [Object] removes and returns one element from session stored analytics
      def shift
        @delayed_store.shift
      end

      module Helper
        def analytics_session
          @analytics_session ||= ThreeScale::Analytics::SessionStoredAnalytics.new(session)
        end
      end

      class Delayed < BasicObject
        def initialize(store)
          @store = store
        end

        def method_missing(key, *args)
          @store.push [key, *args]
        end
      end

      private_constant :Delayed
    end
  end
end
