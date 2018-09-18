require 'ostruct'

module ThreeScale
  module Analytics
    class Credentials

      delegate :google_async_tag,
               :twitter_remarketing, :twitter_conversion,
               :adwords, :prog_web,
               :mixpanel,
               :munchkin,
               to: :@config

      def initialize(config)
        @config = OpenStruct.new(config.to_h)
      end
    end
  end
end
