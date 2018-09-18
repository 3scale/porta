module TestHelpers
  module FakeWeb
    module Keys

      # POST .../keys.xml
      #
      #
      def fake_backend_create_key(name, application_id = @application_id, service_id = @service_id, provider_key = @provider_key)
        body = %(<key value="#{name}" href="#{fake_app_url("/keys/#{name}.xml", application_id)}"/>)
        ::FakeWeb.register_uri( :post, fake_app_url("/keys.xml", application_id),
                                :status => [201, 'Created'],
                                :content_type => CONTENT_TYPE,
                                :body =>  body )
      end

      def fake_backend_key_created?(application_id = @application_id, provider_key = @provider_key)
        request = ::FakeWeb.last_request
        request.method == 'POST' &&  request.path =~ /keys.xml\?/
      end

      # GET .../keys.xml?provider_key=...
      #
      #
      def fake_backend_get_keys(result, application_id = @application_id, service_id = @service_id, provider_key = @provider_key)
        keys = Array(result).map do |k|
          %(<key value="#{k}" href="#{fake_app_url('/keys/' + k + '.xml', application_id)}"/>)
        end

        ::FakeWeb.register_uri( :get, fake_app_url("/keys.xml?provider_key=#{provider_key}&service_id=#{service_id}", application_id),
                                :status => [200, 'OK'],
                                :content_type => CONTENT_TYPE,
                                :body => "<keys>#{keys.join("\n")}</keys>")
      end

      # DELETE .../keys/#{name}.xml?provider_key=...&service_id=...
      #
      #
      def fake_backend_delete_key(name, application_id = @application_id, service_id = @service_id, provider_key = @provider_key)
        ::FakeWeb.register_uri( :delete, fake_app_url("/keys/#{name}.xml?provider_key=#{provider_key}&service_id=#{service_id}", application_id),
                                :status => [200, 'OK'], :body => '' )
      end

    end
  end
end
