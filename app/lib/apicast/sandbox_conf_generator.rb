class Apicast::SandboxConfGenerator < Apicast::ConfGenerator
  abstract!

  class_attribute :config
  self.config = System::Application.config.three_scale.sandbox_proxy.dup.freeze

  def assigns
    {
      # master_provider_key is used to track the proxy traffic by 3scale
      master_provider_key: Account.master.provider_key,
      nginx_port: config.fetch(:nginx_port),
      backend_host: config.fetch(:backend_host),
      backend_scheme: config.fetch(:backend_scheme),
      generator: self,
      timestamp: Time.now.utc.iso8601
    }
  end
end
