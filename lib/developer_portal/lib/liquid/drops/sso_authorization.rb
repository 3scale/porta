# frozen_string_literal: true

module Liquid
  module Drops
    class SSOAuthorization < Drops::Base

      def initialize(authorization)
        @authorization = authorization
      end

      desc 'Returns the authentication provider name.'
      example %(
        {% for authorization in current_user.sso_authorizations %}
          <p>{{ authorization.authentication_provider_system_name }}</p>
        {% endfor %}
      )
      delegate :system_name, prefix: true, to: :authentication_provider, allow_nil: true

      desc 'Returns the id_token.'
      example %(
        {% for authorization in current_user.sso_authorizations %}
          <p>{{ authorization.id_token }}</p>
        {% endfor %}
      )
      delegate :id_token, to: :@authorization

      private

      def authentication_provider
        @authorization.authentication_provider
      end

    end
  end
end
