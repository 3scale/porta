begin
  require 'segment/analytics'
rescue LoadError
  Rails.logger.debug('analytics-ruby gem cannot be loaded. Not reporting to Segment.io')
end

module ThreeScale
  module Analytics
    class UserTracking

      error_handler = lambda do |status, error|
        System::ErrorReporting.report_error(error_message: error, parameters: { status: status })
      end

      class TrackingAdapter
        DELEGATED_METHODS = %i(flush track identify group).freeze
        delegate(*DELEGATED_METHODS, to: :@adapter)

        class NullAdapter
          def with_options(*)
            self
          end

          def respond_to_missing?(method_sym, include_all)
            DELEGATED_METHODS.include?(method_sym) || super
          end

          def method_missing(method_sym, *args, &block)
            DELEGATED_METHODS.include?(method_sym) || super
          end
        end

        def segment_configured?
          defined?(::Segment)
        end

        def initialize(config = {})
          @adapter = segment_configured? ? ::Segment::Analytics.new(config) : NullAdapter.new
        end
      end

      config = ThreeScale.config.segment
      Segment = TrackingAdapter.new(config.merge(on_error: error_handler))

      include ::ThreeScale::MethodTracing

      class << self
        delegate :flush, to: 'ThreeScale::Analytics::UserTracking::Segment', allow_nil: true
      end

      attr_reader :segment, :user
      protected :segment

      def initialize(user, basic_traits: nil, group_traits: nil, identified: false)
        @user = user
        @identified = identified
        @basic_traits = basic_traits
        @group_traits = group_traits
        @account = @user.try!(:account)
        @segment = segment_client
      end

      def basic_traits
        return {} unless @user && @account
        @basic_traits ||= {
            role: @user.role,
            email: @user.email,
            created: @account.created_at,
            firstName: @user.first_name,
            lastName: @user.last_name,
            lastSeen: Time.now,
            name: @user.full_name,
            username: @user.username,
            phone: @account.telephone_number,
            organization: @account.org_name,

            # custom traits
            account: @account.name,
            signup_type: @user.signup_type,
            account_type: extra_fields['account_type'], # to differentiate 3scale from customers
            account_state: @account.state,
            user_type: user_type,
            partner_id: @account.partner_id,

            days_alive: days_alive.to_i,

            api_status: extra_fields['API_Status_3s__c'],
            api_purpose: extra_fields['API_Purpose_3s__c'],
            api_type: extra_fields['API_Type_3s__c'],
            on_prem: extra_fields['API_Onprem_3s__c'],
            rh_login: extra_fields['red_hat_account_number'],
            rh_login_verified_by: extra_fields['red_hat_account_verified_by'],
            signup_origin: extra_fields['Signup_origin'],
            partner: extra_fields['partner'],

            account_id: @account.id,
            domain: @account.domain,
            self_domain: @account.self_domain
        }
      end

      alias traits basic_traits

      def group_traits
        return {} unless @account

        @group_traits ||= {
            name: @account.name,
            plan: (plan = @account.bought_plan).name,
            monthly_spend: (plan_cost = plan.cost_per_month.to_f),
            license_mrr: plan_cost,
            state: @account.state
        }
      end

      def extended_traits
        @_extended_traits ||= begin
          deployment_options = @account.services.pluck(:deployment_option)

          developer_accounts = @account.buyer_accounts.grouping{ state }.count.transform_keys do |state|
            "developer_accounts_#{state}".to_sym
          end

          developer_applications = @account.buyer_applications.grouping{ state }.count.transform_keys do |state|
            "developer_applications_#{state}".to_sym
          end

          {  # TODO: this is making two counts in db every request
             # caused by: b1e21a9a7a638c4f51d997452bd4c0be05209944
             active_docs: @account.api_docs_services.count,
             active_docs_published: @account.api_docs_services.published.count,

             deployment_options: deployment_options.join(','),
             deployment_option: deployment_options.group_by{|o| o }.values.max_by(&:size).try!(:first),
             services: @account.services.size,

             plan: @account.bought_plan.name,
          }.merge(developer_accounts).merge(developer_applications)
        end
      end

      add_three_scale_method_tracer :extended_traits, 'Custom/ThreeScale::Analytics::UserTracking#extended_traits'

      def all_traits
        basic_traits.merge(extended_traits)
      end

      def flush
        Segment.flush
      end

      def experiment(name, variation)
        name = "Experiment: #{name}"
        identify(name => variation)
        track(name, variation: variation)
      end

      def track(event, properties = {})
        # Segment documentation: https://segment.com/docs/integrations/mixpanel/#server-side
        # says that it is necessary to send identify before track.
        # but skip Heap, because we would have to upgrade our plan and are not sure about it
        with_segment_options(integrations: { Heap: false }) do
          identify
        end unless identified?

        Rails.logger.debug { "#{self.class}: #{event} (user: #{user_id}) #{properties}" }

        if can_send?
          segment.track(event: event, properties: properties)
        end
      end

      def identify(custom_traits = {})
        Rails.logger.debug { "#{self.class}: identify (user: #{user_id}) #{custom_traits}" }

        traits = basic_traits.deep_merge(custom_traits)

        if can_send?
          segment.identify(traits: traits)

          @identified = true

          traits
        end
      end

      def group(custom_traits = {})
        traits = group_traits.deep_merge(custom_traits)

        Rails.logger.debug { "#{self.class}: group (group_id: #{group_id}) #{custom_traits}" }

        if can_send?
          segment.group(group_id: group_id, traits: traits)
          traits
        end
      end

      # Can call analytics method once in period
      #
      # @example Call identify once an hour (for example after every page view)
      #   analytics.cached(1.hour).identify
      #
      def cached(period)
        cached = CachedCalls.new(self, period, ::Rails.cache)
        yield cached if block_given?
        cached
      end

      def cache_key
        "user-tracking/user:#{@user.id}"
      end

      def can_send?
        user_id && @account.try!(:provider?) && user_type != 'impersonation_admin'
      end

      def with_segment_options(options)
        segment = @segment
        @segment = segment_client(options)

        yield if block_given?
      ensure
        @segment = segment
      end

      protected

      def identified?
        @identified
      end

      def segment_client(options = {})
        merged_options = segment_options.deep_merge(options)
        Segment.with_options(merged_options) { |segment| return segment }
      end

      def segment_options
        { user_id: user_id, context: context }
      end

      def context
        { ip: 0, active: false, traits: basic_traits, group_id: group_id }
      end

      def user_id
        @user.try!(:id)
      end

      def group_id
        @account.try!(:id)
      end

      def extra_fields
        @account.try(:extra_fields) || {}
      end

      def user_extra_fields
        @user.try(:extra_fields) || {}
      end

      def partner
        return unless @account.partner_id
        cached(1.day).partner_name
      end

      def partner_name
        @account.partner.try!(:system_name)
      end

      def user_type
        @_user_type ||= UserClassifier.classify(@user).underscore
      end

      def days_alive
        (Time.now - @account.created_at) / 1.day
      end

      class CachedCalls < BasicObject
        # Delegates method only once in period.
        # Is using Rails cache with expire to do so.
        #
        # Note: Delegate has to respond to #cache_key
        #
        # @example Call Analytics once an hour
        #   cached = CachedCalls.new(object, 1.hour, cache)
        #   cached.expensive_call # calls object.expensive_call
        #   cached.expensive_call # does not happen

        def initialize(delegate, period, cache)
          @delegate = delegate
          @period = period
          @cache = cache
        end

        def track(event, properties = {})
          cached(:track, event, properties)
        end

        def method_missing(method, *args)
          cached(method, args)
        end

        private

        def cached(method, *modifiers, args)
          key = cache_key(method, *modifiers)

          @cache.fetch(key, expires_in: @period) do
            # return the value or true, because falsy values are not cached
            @delegate.public_send(method, *modifiers, *args) || true
          end
        end

        def cache_key(*args)
          [@delegate.cache_key, *args].join('/')
        end
      end

      private_constant :CachedCalls
    end
  end
end
