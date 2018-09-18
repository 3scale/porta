# frozen_string_literal: true

require 'zip'

module Logic
  module NginxProxy
    module Provider
      def generate_proxy_zip
        source = Apicast::ProviderSource.new(self)
        generator = Apicast::ProviderPackageGenerator.new(source)
        tmpfile = File.expand_path("tmp/proxy_configs_#{self.id}.zip")

        ::Zip::OutputStream.open(tmpfile) do |zip|
          generator.each do |file, contents|
            zip.put_next_entry file
            zip.print contents.call
          end
        end

        tmpfile
      end

      def deploy_production_apicast
        return unless proxy_configs.present? && proxy_configs_conf.present?

        staging_lua = proxy_configs.s3_object
        production_lua = staging_lua.bucket.object(".hosted_proxy/sandbox_proxy_#{id}.lua")
        staging_lua.copy_to(production_lua)

        staging_conf = proxy_configs_conf.s3_object
        production_conf = staging_conf.bucket.object(".hosted_proxy_confs/sandbox_proxy_#{id}.conf")
        staging_conf.copy_to(production_conf)

        update_attribute :hosted_proxy_deployed_at, Time.now
      end
    end
  end
end
