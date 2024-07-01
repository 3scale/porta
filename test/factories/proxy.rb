FactoryBot.define do
  factory(:proxy) do
    association :service
    api_backend { 'http://api.example.net:80' }
    secret_token { "123" }
    policies_config { [{name: 'cors', version: '0.0.1', configuration: {foo: 'bar'}}] }
  end

  factory(:proxy_rule) do
    http_method { "GET" }
    delta { 1 }
    sequence(:created_at) { |n| Time.zone.now - n.days }
    sequence(:pattern) { |n| "/foo/bar/#{n}" }
    metric do
      metric_opts = {}
      metric_owner = proxy&.service
      # as far as I can see, a ProxyRule can be owned by a BackendApi or a Proxy
      # while a Metric can be owned by a BackendApi or a Service
      metric_owner ||= owner.is_a?(Proxy) ? owner.service : owner
      metric_opts[:owner] = metric_owner if metric_owner
      association :metric, **metric_opts
    end
    proxy do
      if owner
        owner if owner.is_a?(Proxy)
      elsif @overrides[:metric]
        @overrides[:metric].proxy if @overrides[:metric].is_a?(Service)
      else
        association :proxy
      end
    end
  end

  factory(:proxy_config) do
    content { ({ proxy: { hosts: ['example.com']}}.to_json) }
    environment { 'sandbox' }
    association :proxy
  end
end
