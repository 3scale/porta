module TestHelpers
  module FakeWeb
    CONTENT_TYPE = 'application/vnd.3scale-v2.0+xml'

    def self.included(base)
      base.setup(:setup_fake_web)
      base.teardown(:teardown_fake_web)

      base.class_eval do
        attr_accessor :backend_host
        alias_method :set_backend_host, :backend_host=
      end
    end


    Dir[File.dirname(File.expand_path(__FILE__)) + '/fake_web/*.rb'].each do |file|
      require file
    end

    include Keys
    include ReferrerFilters
    include Transactions

    def fake_backend_url(fragment, query = nil)
      if query
        fragment << "?#{query.to_query}"
      end
      "http://#{backend_host || 'example.org'}" << fragment
    end

    def fake_app_url(fragment, application_id = @application_id)
      fake_backend_url(fake_app_path(fragment, application_id))
    end

    def fake_app_path(fragment, application_id = @application_id)
      "/applications/#{application_id}#{fragment}"
    end

    def fake_service_url(fragment, service_id = @service_id)
      fake_backend_url(fake_service_path(fragment, service_id))
    end

    def fake_service_path(fragment, service_id = @application_id)
      "/services/#{service_id}#{fragment}"
    end

    def sorted_last_body
      # XXX: Order of parameters is not defined. This trick makes it so :)
      ::FakeWeb.last_request.body.to_s.split('&').sort.join('&')
    end

    def fake_referrer_filters_url provider = nil, provider_key = @provider_key, service_id = @service_id
      fake_app_url("/referrer_filters#{'/' << provider if provider}.xml?provider_key=#{provider_key}&service_id=#{service_id}")
    end

    # Helpers
    #
    def setup_fake_web
      require 'fakeweb'
      ::FakeWeb.allow_net_connect = false
      ::FakeWeb.clean_registry
      ::WebMock.disable!
    end

    def teardown_fake_web
      ::FakeWeb.allow_net_connect = true
      ::FakeWeb.clean_registry
      ::WebMock.enable!
    end
  end
end

#ActiveSupport::TestCase.send(:include, TestHelpers::FakeWeb)
