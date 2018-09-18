module TestHelpers
  module FakeWeb
    module ReferrerFilters
      def fake_backend_referrer_filters(filters = [])
        body = %(
<referrer_filters>
  #{ filters.map do |filter|
       %{<referrer_filter value="#{filter}" href="#{fake_app_url("/referrer_filters/#{filter}")}"/>}
  end.join }
</referrer_filters>)
        ::FakeWeb.register_uri :get, fake_referrer_filters_url,
                               status: [200, 'OK'],
                               content_type: CONTENT_TYPE,
                               body: body
      end

      def fake_backend_create_referrer_filter(filter)
        body = %(<referrer_filter value="#{filter}" href="#{fake_app_url("/referrer_filters/#{filter}")}"/>)
        ::FakeWeb.register_uri :post, fake_app_url("/referrer_filters.xml"),
                               status: [201, 'Created'],
                               content_type: CONTENT_TYPE,
                               body: body
      end

      def fake_backend_invalid_referrer_filter error
        body = %(<error code="#{error[:code]}">#{error[:message]}</error>)
        ::FakeWeb.register_uri :post, fake_app_url("/referrer_filters.xml"),
                               status: [422, 'Unprocessable Entity'],
                               content_type: CONTENT_TYPE,
                               body: body
      end

      def fake_backend_delete_referrer_filter(filter)
        encoded_filter = Base64.urlsafe_encode64(filter)
        ::FakeWeb.register_uri :delete,
                               fake_referrer_filters_url(encoded_filter),
                               status: [200, 'OK'], body: ''
      end
    end
  end
end
