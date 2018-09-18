module Liquid
  module Drops
    module AuthenticationStrategy
      class Base < Drops::Base
        def initialize(strategy)
          @strategy = strategy
        end

        def login_url
          @strategy.login_url_with_service
        end

        def user_identified?
          !!@strategy.user_for_signup
        end
      end

      class Cas < Base
        allowed_names :cas
      end

    end
  end
end
