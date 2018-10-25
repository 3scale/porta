# frozen_string_literal: true

module Logic
  module Backend

    # TODO: Unify this with BackendVersion in lib/backend_version.rb
    class Version
      def initialize(version)
        @version = version.to_s
      end

      def user_key?
        @version == '1'
      end

      def app_id?
        @version == '2'
      end

      def oauth?
        @version == 'oauth'
      end

      def ==(other)
        super or @version == other
      end
    end

    # TODO: change it into cancan rule
    module Service

      VERSIONS = {
        I18n.t("api_key", scope: :authentication_options) => "1",
        I18n.t("key_pair", scope: :authentication_options) => "2",
        I18n.t("oauth", scope: :authentication_options)=> "oauth",
        I18n.t("oidc", scope: :authentication_options)=> "oidc",
      }

      def self.available_versions_for(service)
        VERSIONS.select do |_, version|
          case version
          when 'oidc'
            service.account.provider_can_use?(:apicast_oidc) && (service.proxy || service.build_proxy).apicast_configuration_driven
          else
            true
          end
        end
      end

      def app_keys_allowed?
        self.backend_version >= "2"
      end
    end
  end
end
