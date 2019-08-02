require 'google/api_client'

module ThreeScale
  module Analytics

    # Integration with Google Analytics Experiments for A/B testing
    # GoogleExperiments.fetch_info and GoogleExperiments.api_client handle the connection to Google APIs
    #
    # To properly configure the API Client, you need to create a project on google dashboard:
    # https://console.developers.google.com/project?authuser=1
    # Then Enable an API > Analytics API > Enable API
    # Then in sidebar APIs & Auth > Credentials > Create new Client ID
    #   > choose 'Service account' > press Create Client ID which downloads you a JSON
    #
    # Then run a rake google_experiments:configuration < ~/Downloads/Project-Name-someid.json
    # and add the configuration to correct environment.
    #
    # Then you have to enable API Access in our Google Apps for this Client ID.
    # rake google_experiments:configuration prints the steps.
    # Go to https://admin.google.com/3scale.net/ManageOauthClients
    # and add Client ID (the one without @) and scope https://www.googleapis.com/auth/analytics.readonly

    class GoogleExperiments

      ACCESS_SCOPE = 'https://www.googleapis.com/auth/analytics.readonly'.freeze
      MATCHER = /\.(?<experiment>[^\$]+)\$\d+:(?<variant>\d)/

      delegate :to_a, :each, :empty?, :size, to: :@experiments

      def initialize(experiments)
        @experiments = experiments
      end

      def to_hash
        each.reduce({}) {|combined, experiment| combined.merge(experiment) }
      end

      def presence
        @experiments.presence ? self : nil
      end

      class << self
        include ::ThreeScale::MethodTracing

        def config
          ThreeScale.config.google_experiments
        end

        # noinspection RubyResolve
        def fetch_info(experiment_id)
          client = api_client

          experiment = client.discovered_api('analytics', 'v3').management.experiments.get

          result = client.execute(api_method: experiment,
                                  parameters: {
                                      accountId: config.account_id.to_s,
                                      profileId: config.profile_id.to_s,
                                      webPropertyId: config.web_property_id.to_s,
                                      experimentId: experiment_id
                                  })
          {
              name: result.data.name,
              variations:  result.data.variations.map(&:name)
          }
        end

        def from_cookie(value)
          matches = value.to_s.scan(MATCHER)

          experiments = matches.map do |(id, variation)|
            experiment(id, variation)
          end

          new(experiments)
        end

        def experiment(id, variation)
          Experiment.new(id, variation)
        end

        def enabled?
          config.enabled
        end

        protected

        def api_client
          key = OpenSSL::PKey::RSA.new(config.private_key)
          # noinspection RubyResolve
          auth_client = Signet::OAuth2::Client.new(
              token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
              audience: 'https://accounts.google.com/o/oauth2/token',
              scope: ACCESS_SCOPE,
              issuer: config.issuer,
              signing_key: key,
              person: config.person
          )

          client = Google::APIClient.new(authorization: auth_client,
                                         application_name: '3scale System',
                                         application_version: '0.0.1')

          auth_client.fetch_access_token!(connection: client.connection)
          client
        end

        add_three_scale_method_tracer :api_client, 'Custom/GoogleExperiments.api_client'
      end

      class Experiment
        include ::ThreeScale::MethodTracing

        attr_reader :id, :variation

        def initialize(id, variation)
          @id = id.freeze
          @variation = variation.to_i if variation
        end

        def name
          api_info.fetch(:name)
        end

        def variation_name
          api_info.fetch(:variations)[@variation]
        end

        def api_info
          @_api_info ||= Rails.cache.fetch("threescale-analytics-experiment-#{@id}", &method(:fetch_info))
        end

        def to_hash
          properties = {}

          if name
            properties["Experiment: #{name}"] = variation_name
          end

        rescue => error
          System::ErrorReporting.report_error(error)
        ensure
          return properties
        end

        protected

        def fetch_info(*)
          ActiveSupport::Notifications.instrument('fetch_info.google_experiments',
                                                  name: "Fetching info of experiment #{@id}") do |payload|
            payload[:info] = GoogleExperiments.fetch_info(@id)
          end
        end

        add_three_scale_method_tracer :fetch_info, 'Custom/GoogleExperiments::Experiment#fetch_info'
      end
      private_constant :Experiment

    end
  end
end
