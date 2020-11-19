# frozen_string_literal: true

module System
  module Deploy
    mattr_accessor :info

    module BasicInfo
      def as_json(*)
        super.merge(rails: Rails::VERSION::STRING, env: ENV.to_hash)
      end
    end

    class Info
      include BasicInfo
      attr_reader :revision, :deployed_at, :release

      delegate :minor_version, :major_version, to: :version

      def initialize(info)
        @revision = info.fetch('revision') { `git rev-parse HEAD 2> /dev/null`.strip }
        @release = info.fetch('release', '2.x')
        @deployed_at = info.fetch('deployed_at') { Time.zone.now }
        @error = info.fetch(:error) if info.key?(:error)
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
      include BasicInfo
      attr_reader :release

      def initialize(error)
        @error = error.message
        @backtrace = error.backtrace
        @release = ENV['AMP_RELEASE'].presence
      end
    end

    def self.parse_deploy_info
      path = Rails.root.join('.deploy_info').expand_path
      return { error: { path: path.to_s, message: 'not found' } } unless path.exist?

      ActiveSupport::JSON.decode(path.read)
    end

    def self.call(_)
      [200, {'Content-Type' => 'application/json'}, [info.to_json]]
    end

    def self.load_info!(deploy_info = parse_deploy_info)
      self.info = Info.new(deploy_info)
    rescue StandardError => error
      self.info = InvalidInfo.new(error)
    end
  end
end

System::Deploy.load_info!
