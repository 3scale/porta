module ThreeScale::DevDomain
  def self.enabled?
    ThreeScale.config.dev_domain
  end

  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  included do
    helper URL
  end

  def self.extended(base)
    base.extend URL
  end

  def request
    super.extend(Request)
  end

  def url_options
    options = super
    host = options.fetch(:host)
    real_host = request.real_host(host)
    host.replace(real_host)
    options
  end

  def self.strip(host)
    return host unless enabled?

    host.sub(/\.#{Regexp.escape(ThreeScale.config.dev_gtld)}\Z/, '') # strip trailing .dev from domain
  end

  module Request
    def dev?(host = nil)
      host ||= raw_host_with_port.sub(/:\d+$/, '')
      host.ends_with?(".#{ThreeScale.config.dev_gtld}")
    end

    def host
      ThreeScale::DevDomain.strip(super)
    end

    def host_with_port(override_host = nil)
      real_host(override_host || super())
    end

    def real_host(host = self.host)
      preview_host dev_host(host)
    end

    protected

    def dev_host(host_with_port)
      replace_host(host_with_port) do |host|
        host + ".#{ThreeScale.config.dev_gtld}" if dev? && !dev?(host)
      end
    end

    def preview_host(host_with_port)
      replace_host(host_with_port) do |host|
        forwarded_host = headers['X-Forwarded-For-Domain'].to_s
        forwarded_parts = forwarded_host.split('.')

        if (index = forwarded_parts.index { |s| s =~ /^preview\d+$/ })
          parts = host.split('.')
          preview = forwarded_parts.fetch(index)
          unless parts.include?(preview)
            parts.insert(index, preview)
          end
          parts.join('.')
        end
      end
    end

    def replace_host(host_with_port)
      host, port = host_with_port.split(':')
      new_host = yield(host).presence || host
      [new_host, port].compact.join(':')
    end
  end

  module URL
    def self.options(request, options = {})
      if (host_with_port = options[:host])

        # use dev host only when request came from .dev domain
        # or use host passed from X-Forwarded-For-Domain
        options[:host] = request.real_host(host_with_port)

        if (port = request.port) != request.standard_port
          options[:port] = port # redirect to same port
        end
      end
      options
    end

    def url_for(options = {})
      case options
      when Hash
        options = URL.options(request, options.dup)
      end

      super
    end
  end
end
