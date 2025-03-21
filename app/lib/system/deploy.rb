# frozen_string_literal: true

module System
  module Deploy
    mattr_accessor :info

    DEFAULT_DEPLOY_INFO_PATH = '.deploy_info'
    private_constant :DEFAULT_DEPLOY_INFO_PATH

    # Provides information about the version of the code:
    #   - revision: low-level version, that is used by BugSnag as app version
    #   - release: customer-facing version, that is visible in the admin portal footer
    #   - deployed_at: timestamp of the deployment
    #   - docs_version: product name and the version that are used as prefix for product documentation path in the
    #                   Red Hat Customer Portal
    # The data is taken from the `.deploy_info` file in the root directory, but for SaaS the release
    # is overridden with DEFAULT_VERSION.
    # `.deploy_info` file is injected to the container during container build process in CPaaS (the content is set in Dockerfile)
    # The information is exposed via {MASTER_PORTAL}/deploy endpoint for logged-in users.
    class Info
      DEFAULT_VERSION = '2.x'

      private_constant :DEFAULT_VERSION

      attr_reader :revision, :deployed_at, :release

      delegate :minor_version, :major_version, to: :version

      def initialize(info)
        @revision = info.fetch('revision') { `git rev-parse HEAD 2> /dev/null`.strip }
        @release = ThreeScale.saas? ? DEFAULT_VERSION : info.fetch('release', DEFAULT_VERSION)
        @deployed_at = info.fetch('deployed_at') { Time.now.utc }
        @error = info.fetch(:error) if info.key?(:error)
      end

      def docs_version
        @docs_version ||= ThreeScale.saas? || rhoam? ? '2-saas' : "#{major_version}.#{minor_version}"
      end

      # RHOAM version has only one segment (release = 'RHOAM')
      def rhoam?
        version.segments.count < 2
      end

      private

      class VersionParser
        attr_reader :segments

        def initialize(release)
          @segments = release.to_s.split('.')
        end

        def minor_version
          segments[1]
        end

        def major_version
          segments[0]
        end
      end

      def version
        @version ||= VersionParser.new(release)
      end
    end

    class InvalidInfo
      attr_reader :release

      def initialize(error)
        @error = error.message
        @backtrace = error.backtrace
        @release = ENV['AMP_RELEASE'].presence
      end
    end

    def self.parse_deploy_info(deploy_info_path = DEFAULT_DEPLOY_INFO_PATH)
      path = Rails.root.join(deploy_info_path).expand_path
      return { error: { path: path.to_s, message: 'not found' } } unless path.exist?

      ActiveSupport::JSON.decode(path.read)
    end

    def self.call(_)
      [200, {'Content-Type' => 'application/json'}, [info.to_json]]
    end

    def self.load_info!(deploy_info = parse_deploy_info)
      self.info = Info.new(deploy_info)
    rescue StandardError => exception
      self.info = InvalidInfo.new(exception)
    end
  end
end

System::Deploy.load_info!
