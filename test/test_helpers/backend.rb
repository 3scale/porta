module TestHelpers
  module Backend
    module MockCore
      # Helpers to mock ThreeScale::Core
      #
      # We are currently only partially mocking ThreeScale::Core, enough
      # to have tests passing with current 3scale_core 1.1 and 1.2.
      #
      extend self

      def test_adapter
        stubs = Faraday::Adapter::Test::Stubs.new

        faraday = Faraday.new do |builder|
          builder.adapter :test, stubs
        end
        [ faraday, stubs ]
      end

      def stubs
        @stubs or raise "Missing @stubs, core not mocked"
      end

      def mock_faraday!
        faraday, @stubs = test_adapter
        ThreeScale::Core.instance_variable_set(:@faraday, faraday)
      end

      def mock_core!
        # SCREAM when someone tries to touch Faraday
        mock_faraday!

        # ditto for storage
        raise_on_method ThreeScale::Core.singleton_class, :storage
        # mock Application
        clear_method ThreeScale::Core::Application.singleton_class,
          :save, :delete, :save_id_by_key, :delete_id_by_key
        # mock Metric
        clear_method ThreeScale::Core::Metric.singleton_class,
          :save, :delete, :load
        # mock Service
        clear_method ThreeScale::Core::Service.singleton_class,
          :save!, :load_by_id, :delete_by_id!, :delete_stats
        clear_method ThreeScale::Core::ServiceToken.singleton_class,
          :save!, :delete
        clear_method ThreeScale::Core::UsageLimit.singleton_class,
          :save, :load_value, :delete
        clear_method ThreeScale::Core::User.singleton_class,
          :load, :delete_all_for_service
        clear_method ThreeScale::Core::ApplicationKey.singleton_class,
          :save, :delete
        clear_method ThreeScale::Core::ApplicationReferrerFilter.singleton_class,
          :save, :delete

        # these are required to return true for some cukes to be happy
        on_method ThreeScale::Core::User.singleton_class, :save!, :delete! do |*_|
          true
        end

        clear_method ThreeScale::Core::AlertLimit.singleton_class, :save, :load_all do |*_|
          []
        end
        # add more classes below this point
      end

      private

      def on_method(klass, *methods, &blk)
        blk = proc { |*_| } unless blk
        methods.each do |m|
          klass.send :remove_method, m rescue nil
          klass.send :define_method, m, blk
        end
      end
      alias clear_method on_method

      def raise_on_method(klass, *methods)
        on_method klass, *methods do |*args|
          raise "*** FORBIDDEN CALL to #{klass}.#{__method__}, backtrace:\n#{caller_locations.join("\n")}\n*** END BT ***\n"
        end
      end
    end

    # ALWAYS mock ThreeScale::Core
    MockCore.mock_core!

    def stub_core_integration_errors(service_id: )
      MockCore.stubs.get("/internal/services/#{service_id}/errors/") do
        [ 200, {'content-type'=>'application/json'}, { errors: [] }.to_json ]
      end
    end

    def stub_core_change_provider_key(provider_key)
      MockCore.stubs.put("/internal/services/change_provider_key/#{provider_key}") do
        [ 200, {'content-type'=>'application/json'}, { }.to_json ]
      end
    end

    def stub_core_reset!
      MockCore.mock_faraday!
    end

    def create_master_account_metrics
      master_service = ::Account.master.default_service
      hits = master_service.metrics.find_by_name('hits')
      FactoryBot.create(:metric, :parent => hits, :service => master_service, :name => 'transactions/create_single')
      FactoryBot.create(:metric, :parent => hits, :service => master_service, :name => 'transactions/create_multiple')
      FactoryBot.create(:metric, :parent => hits, :service => master_service, :name => 'transactions/confirm')
      FactoryBot.create(:metric, :parent => hits, :service => master_service, :name => 'transactions/destroy')
      FactoryBot.create(:metric, :parent => hits, :service => master_service, :name => 'transactions/authorize')
    end

    def make_transaction_at(time, options)
      Timecop.freeze(time) do
        options = options.reverse_merge(:provider_account_id => @provider_account.id,
                                        :service_id => @service.id,
                                        :usage => {'hits' => 1},
                                        :confirmed => true,
                                        :log => {'code' => 200},
                                       )

        ::Backend::Transaction.report!(options)
      end
    end

    def assert_change_in_usage(options, &block)
      stats = if options[:service]
                Stats::Service.new(options[:service])
              else
                Stats::Client.new(options[:cinstance] || @cinstance)
              end

      stats_options = {:metric => options[:metric] || @metric,
                       :period => options[:period] || :eternity,
                       :since  => options[:since]}

      change_options = options.slice(:from, :to, :by)
      change_options[:of] = lambda { stats.total(stats_options) }

      assert_change change_options, &block
    end

    def assert_no_change_in_usage(options = {}, &block)
      assert_change_in_usage options.merge(:by => 0), &block
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::Backend)
