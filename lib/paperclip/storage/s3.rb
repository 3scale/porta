# This module adds the ability for Paperclip to work with AWS STS.
# Once we migrate from Paperclip to ActiveStorage, this file should be removed.
module Paperclip
  module Storage
    module S3
      def s3_interface
        @s3_interface ||= begin
          config = { region: s3_region }

          if using_http_proxy?

            proxy_opts = { :host => http_proxy_host }
            proxy_opts[:port] = http_proxy_port if http_proxy_port
            if http_proxy_user
              userinfo = http_proxy_user.to_s
              userinfo += ":#{http_proxy_password}" if http_proxy_password
              proxy_opts[:userinfo] = userinfo
            end
            config[:proxy_uri] = URI::HTTP.build(proxy_opts)
          end

          config[:use_accelerate_endpoint] = use_accelerate_endpoint?

          # Add :session_token as a valid argument
          [:access_key_id, :secret_access_key, :credential_provider, :credentials, :session_token].each do |opt|
            config[opt] = s3_credentials[opt] if s3_credentials[opt]
          end

          obtain_s3_instance_for(config.merge(@s3_options))
        end
      end
    end
  end
end
